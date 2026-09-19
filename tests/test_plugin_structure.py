from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
PLUGIN = ROOT / "plugins" / "neural-open-code"
CORE_SKILLS = {"discover", "spec", "craft", "vet", "exercise"}


def _load(path: Path) -> dict[str, object]:
    return json.loads(path.read_text(encoding="utf-8"))


def test_package_has_valid_opencode_plugin_shape() -> None:
    manifest = _load(PLUGIN / "package.json")
    assert manifest["name"] == "neural-open-code"
    assert manifest["version"] == "2.0.0"
    assert manifest["type"] == "module"
    assert manifest["main"] == "./index.js"
    assert manifest["exports"]["./server"] == "./index.js"
    assert manifest["engines"]["opencode"] == ">=1.18.31"
    assert manifest["repository"]["url"] == "https://github.com/brolag/neural-open-code.git"
    assert manifest["homepage"] == "https://brolag.github.io/neural-open-code/"
    assert manifest["author"] == {
        "name": "Alfredo Bonilla",
        "url": "https://github.com/brolag",
    }
    assert "mcpServers" not in manifest
    assert "config" not in manifest


def test_plugin_entry_registers_opencode_hooks_only() -> None:
    text = (PLUGIN / "index.js").read_text(encoding="utf-8")
    assert 'export const id = "neural-open-code"' in text
    assert "tool.execute.before" in text
    assert "tool.execute.after" in text
    assert "experimental.session.compacting" in text
    assert 'config:' not in text
    assert "mcpServers" not in text
    assert "Does not mutate model" in text


def test_example_config_is_reversible_and_local() -> None:
    example = _load(ROOT / "opencode.example.json")
    assert example["plugin"] == ["./plugins/neural-open-code"]
    assert example["skills"] == {"paths": ["./plugins/neural-open-code/skills"]}
    assert "model" not in example
    assert "permission" not in example
    assert "mcp" not in example


def test_plugin_contains_exactly_the_reviewed_skills() -> None:
    skills_root = PLUGIN / "skills"
    actual = {path.name for path in skills_root.iterdir() if path.is_dir()}
    assert actual == CORE_SKILLS
    for name in CORE_SKILLS:
        assert (skills_root / name / "SKILL.md").is_file()


def test_no_duplicate_or_legacy_distribution_roots_remain() -> None:
    for relative in (
        ".opencode",
        "install.sh",
        "ONE-LINER-INSTALL.md",
        "scripts/setup-hooks.sh",
        "scripts/neural-loop",
        ".codex-plugin",
        "plugins/neural-codex",
    ):
        assert not (ROOT / relative).exists(), relative

    skill_files = {path for path in ROOT.glob("**/SKILL.md") if "archived/" not in path.as_posix()}
    expected = {PLUGIN / "skills" / name / "SKILL.md" for name in CORE_SKILLS}
    assert skill_files == expected


def test_archived_1_9_0_is_explicitly_unsupported() -> None:
    note = ROOT / "archived" / "v1.9.0" / "UNSUPPORTED.md"
    assert note.is_file()
    text = note.read_text(encoding="utf-8")
    assert "unsupported" in text.lower()
    assert "/course" in text
    assert "/loop" in text
