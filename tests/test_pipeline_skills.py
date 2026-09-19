from __future__ import annotations

from pathlib import Path

PIPELINE_SKILLS = ["discover", "spec", "craft", "vet", "exercise"]


def _root() -> Path:
    return Path(__file__).resolve().parents[1]


def _skill_text(name: str) -> str:
    return (_root() / ".opencode" / "skills" / name / "SKILL.md").read_text(encoding="utf-8")


def _frontmatter_keys(text: str) -> set[str]:
    lines = text.splitlines()
    assert lines and lines[0] == "---"
    end = lines.index("---", 1)
    return {
        line.split(":", 1)[0].strip()
        for line in lines[1:end]
        if line and not line.startswith((" ", "\t")) and ":" in line
    }


def test_pipeline_skills_have_opencode_shape() -> None:
    for name in PIPELINE_SKILLS:
        text = _skill_text(name)
        assert _frontmatter_keys(text) == {"name", "description"}
        assert f"name: {name}" in text
        assert "## Usage Examples" in text


def test_discover_hands_a_grounded_map_to_spec() -> None:
    text = _skill_text("discover")
    for term in (
        "blindspot pass",
        "Known knowns",
        "unknowns-map.md",
        "$spec",
        "Do not modify application code",
    ):
        assert term in text
    reference = _root() / ".opencode" / "skills" / "discover" / "references" / "unknowns-framework.md"
    assert "status: ready-for-spec | blocked" in reference.read_text(encoding="utf-8")


def test_spec_stops_for_approval() -> None:
    text = _skill_text("spec")
    for term in ("plan.md", "status: draft", "STOP for approval", "Do not generate HTML"):
        assert term in text


def test_quality_gates_use_international_standards() -> None:
    spec = _skill_text("spec")
    vet = _skill_text("vet")
    exercise = _skill_text("exercise")
    discover = _skill_text("discover")
    for text in (spec, vet, discover):
        for term in ("OWASP ASVS", "ISO/IEC 25010", "WCAG 2.2"):
            assert term in text
    assert "axe" in exercise.lower() or "Lighthouse" in exercise
    assert "not an exercise gate" in exercise.lower()


def test_craft_requires_independent_gates() -> None:
    text = _skill_text("craft")
    for term in (
        "status: approved",
        "baseline.md",
        "$vet --spec",
        "$exercise --spec",
        "three quality gates",
    ):
        assert term in text


def test_vet_and_exercise_are_separate_gates() -> None:
    vet = _skill_text("vet")
    exercise = _skill_text("exercise")
    assert "SHIP" in vet and "HOLD" in vet
    assert "PASS" in exercise and "FAIL" in exercise


def test_skills_do_not_reference_removed_harness_surfaces() -> None:
    banned = (
        ".claude/skills/",
        "allowed-tools",
        "AskUserQuestion",
        "install.sh",
        "OPENCODE_PLUGIN_ROOT",
    )
    for name in PIPELINE_SKILLS:
        text = _skill_text(name)
        for term in banned:
            assert term not in text, f"Unsupported contract {term!r} in {name}"
