from __future__ import annotations

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / "plugins" / "neural-open-code"
HOOKS = PLUGIN / "hooks"


def test_hook_modules_are_dependency_free_javascript() -> None:
    required = {
        "dangerous-actions.js",
        "sensitive-files.js",
        "prompt-injection.js",
        "output-scanner.js",
        "pre-compact.js",
        "README.md",
    }
    actual = {path.name for path in HOOKS.iterdir()}
    assert required <= actual
    for name in required:
        if name.endswith(".js"):
            text = (HOOKS / name).read_text(encoding="utf-8")
            assert "require(" not in text
            for match in (line for line in text.splitlines() if " from " in line):
                assert "node:" in match or match.strip().endswith('.js"')


def test_plugin_does_not_mutate_host_policy_hooks() -> None:
    text = (PLUGIN / "index.js").read_text(encoding="utf-8")
    for term in ('"config"', "permission.ask", "mcpServers", "chat.params"):
        assert term not in text
    assert "throw new Error(reason)" in text


def test_hooks_readme_states_visible_trust_limits() -> None:
    text = (HOOKS / "README.md").read_text(encoding="utf-8")
    assert "tool.execute.before" in text
    assert "experimental.session.compacting" in text
    assert "not a sandbox" in text
    assert "no `/hooks` trust UI" in text or "no separate hook-trust UI" in text
