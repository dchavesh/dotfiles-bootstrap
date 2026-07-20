# Playwright across the WSL/Windows boundary

Code lives in WSL; sometimes a test needs to exercise the *actual*
Windows-side Chrome (real Windows network stack, proxy/cert store, GPU
context) rather than the Linux Chrome Playwright normally drives. Both
Chromes are installed by the bootstrap (`wsl/07-chrome-playwright.sh` on
the Linux side, `windows/packages.json` → `Google.Chrome.EXE` on the
Windows side) — this just wires both into one `playwright.config.ts`.

```ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  projects: [
    {
      // Default: native Linux Chrome, installed via apt. No extra
      // `playwright install` needed for this channel. Use for normal
      // and headless/CI runs.
      name: 'wsl-chrome',
      use: { ...devices['Desktop Chrome'], channel: 'chrome' },
    },
    {
      // Launches the Windows-side Chrome as a Windows process via WSL
      // interop. Slower to start and opens a real GUI window unless you
      // also pass '--headless' through launchOptions.args. Use only when
      // a test specifically needs Windows' own rendering/network context.
      name: 'windows-chrome',
      use: {
        ...devices['Desktop Chrome'],
        launchOptions: {
          executablePath: '/mnt/c/Program Files/Google/Chrome/Application/chrome.exe',
        },
      },
    },
  ],
});
```

Run one or the other with `npx playwright test --project=wsl-chrome` /
`--project=windows-chrome`.

Playwright's own bundled Chromium (`~/.cache/ms-playwright`, populated by
`npx playwright install` per-project) still works as a third, default
option if a test doesn't specify a `channel` or `executablePath` at all —
neither of the two projects above is required unless you specifically need
one side or the other.
