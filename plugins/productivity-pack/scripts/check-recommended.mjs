#!/usr/bin/env node
// /productivity-pack:check-recommended — marketplace 권장 플러그인 설치 상태 조회
//
// Phase 5 §4.6.2 manual command logic. Non-blocking: 어떤 단계가 실패해도
// non-zero exit을 내지 않고 안내 메시지와 함께 종료한다.
//
// env override:
//   RWANG_INSTALLED_PLUGINS_PATH — 설치 목록 JSON 경로 (검증·fixture용).
//     설정 시 실 `~/.claude/plugins/installed_plugins.json`은 읽지 않는다.

import { existsSync, readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const INSTALL_LIST =
  process.env.RWANG_INSTALLED_PLUGINS_PATH ||
  join(homedir(), '.claude', 'plugins', 'installed_plugins.json');

function findMarketplaceRoot() {
  const seeds = [];
  if (process.env.CLAUDE_PLUGIN_ROOT) {
    seeds.push(process.env.CLAUDE_PLUGIN_ROOT);
  }
  seeds.push(dirname(fileURLToPath(import.meta.url)));

  for (const seed of seeds) {
    let cur = resolve(seed);
    while (true) {
      const candidate = join(cur, '.claude-plugin', 'marketplace.json');
      if (existsSync(candidate)) {
        return { root: cur, marketplacePath: candidate };
      }
      const parent = dirname(cur);
      if (parent === cur) break;
      cur = parent;
    }
  }
  return null;
}

function readJson(path) {
  let raw;
  try {
    raw = readFileSync(path, 'utf8');
  } catch (e) {
    if (e.code === 'ENOENT') return { ok: false, reason: 'file-missing' };
    return { ok: false, reason: 'read-failed', error: e.message };
  }
  try {
    return { ok: true, data: JSON.parse(raw) };
  } catch (e) {
    return { ok: false, reason: 'parse-failed', error: e.message };
  }
}

function getInstalledUserPlugins() {
  const r = readJson(INSTALL_LIST);
  if (!r.ok) return r;
  const data = r.data;
  if (
    !data ||
    typeof data !== 'object' ||
    !data.plugins ||
    typeof data.plugins !== 'object' ||
    Array.isArray(data.plugins)
  ) {
    return { ok: false, reason: 'unexpected-schema' };
  }
  const names = Object.keys(data.plugins).filter((key) => {
    const entries = data.plugins[key];
    return Array.isArray(entries) && entries.some((e) => e?.scope === 'user');
  });
  return { ok: true, names };
}

function extractPluginKey(rec) {
  // installed_plugins.json의 키는 "<name>@<marketplace>" 형태도 "<name>"도 가능.
  // recommends.json의 name만으로 느슨하게 매칭: 키의 '@' 앞부분이 일치하면 설치로 본다.
  const local = rec.split('@')[0];
  return local;
}

function isInstalled(recName, installedKeys) {
  return installedKeys.some((k) => extractPluginKey(k) === recName);
}

function printWarning(reason) {
  console.log(
    [
      '💡 권장 플러그인 상태를 자동 확인하지 못했습니다.',
      `   (사유: ${reason})`,
      '   /plugin list 로 직접 확인하거나 docs/RECOMMENDED_PLUGINS.md 를 참조하세요.',
    ].join('\n'),
  );
}

function main() {
  const market = findMarketplaceRoot();
  if (!market) {
    printWarning('marketplace-not-found');
    return;
  }

  const mp = readJson(market.marketplacePath);
  if (!mp.ok) {
    printWarning(mp.reason);
    return;
  }
  if (!mp.data || !Array.isArray(mp.data.plugins)) {
    printWarning('unexpected-schema');
    return;
  }

  const installed = getInstalledUserPlugins();
  let installedKeys = [];
  let installedWarn = null;
  if (installed.ok) {
    installedKeys = installed.names;
  } else {
    installedWarn = installed.reason;
  }

  const rows = [];
  for (const pack of mp.data.plugins) {
    const packDir = resolve(market.root, pack.source || `./plugins/${pack.name}`);
    const recPath = join(packDir, '.claude-plugin', 'recommends.json');
    if (!existsSync(recPath)) continue;
    const rec = readJson(recPath);
    if (!rec.ok) {
      rows.push({
        pack: pack.name,
        plugin: '(read error)',
        status: `⚠️ ${rec.reason}`,
        reason: '',
      });
      continue;
    }
    const list = Array.isArray(rec.data?.recommends) ? rec.data.recommends : [];
    if (list.length === 0) continue;
    for (const r of list) {
      const status = installed.ok
        ? isInstalled(r.name, installedKeys)
          ? '✅'
          : '❌'
        : '—';
      rows.push({
        pack: pack.name,
        plugin: r.name,
        status,
        reason: r.reason || '',
      });
    }
  }

  if (rows.length === 0) {
    console.log('(권장 플러그인 엔트리를 가진 팩이 없습니다.)');
    if (installedWarn) printWarning(installedWarn);
    return;
  }

  const headers = ['팩', '권장 플러그인', '설치', '용도'];
  const widths = headers.map((h, i) => {
    const col = [h, ...rows.map((r) => [r.pack, r.plugin, r.status, r.reason][i])];
    return Math.max(...col.map((s) => String(s).length));
  });
  const pad = (s, w) => String(s) + ' '.repeat(Math.max(0, w - String(s).length));
  const line = (cells) => '| ' + cells.map((c, i) => pad(c, widths[i])).join(' | ') + ' |';
  const sep = '|' + widths.map((w) => '-'.repeat(w + 2)).join('|') + '|';
  console.log(line(headers));
  console.log(sep);
  for (const r of rows) {
    console.log(line([r.pack, r.plugin, r.status, r.reason]));
  }
  if (installedWarn) {
    console.log('');
    printWarning(installedWarn);
  }
}

main();
