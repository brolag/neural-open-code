from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CORE_SKILLS = {"discover", "spec", "craft", "vet", "exercise"}


def test_opencode_json_is_valid() -> None:
    cfg = json.loads((ROOT / "opencode.json").read_text(encoding="utf-8"))
    assert cfg["$schema"] == "https://opencode.ai/config.json"
    assert "AGENTS.md" in cfg["instructions"]


def test_plugin_file_exists() -> None:
    path = ROOT / ".opencode" / "plugin" / "neural-hooks.js"
    assert path.is_file()
    text = path.read_text(encoding="utf-8")
    assert "export default" in text
    assert "tool.execute.before" in text


def test_exactly_five_skills_and_commands() -> None:
    skills_root = ROOT / ".opencode" / "skills"
    commands_root = ROOT / ".opencode" / "commands"
    skills = {path.name for path in skills_root.iterdir() if path.is_dir()}
    commands = {path.stem for path in commands_root.glob("*.md")}
    assert skills == CORE_SKILLS
    assert commands == CORE_SKILLS
    for name in CORE_SKILLS:
        assert (skills_root / name / "SKILL.md").is_file()
        assert (commands_root / f"{name}.md").is_file()


def test_no_legacy_distribution_roots() -> None:
    for relative in (
        "install.sh",
        "hooks/hooks.json",
        "scripts/setup-hooks.sh",
        "scripts/neural-loop",
        "output-styles",
        ".opencode/skills-registry.json",
    ):
        assert not (ROOT / relative).exists(), relative

    skill_files = set(ROOT.glob("**/SKILL.md"))
    expected = {ROOT / ".opencode" / "skills" / name / "SKILL.md" for name in CORE_SKILLS}
    assert skill_files == expected
