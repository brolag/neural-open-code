from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
CORE_SKILLS = ("discover", "spec", "craft", "vet", "exercise")
FLOW_DOCS = (
    ROOT / "README.md",
    ROOT / "docs" / "README.md",
    ROOT / "docs" / "WORKFLOW.md",
    ROOT / "docs" / "index.html",
)
PUBLIC_DOCS = (
    ROOT / "README.md",
    ROOT / "AGENTS.md",
    ROOT / "ARCHITECTURE.md",
    *(path for path in (ROOT / "docs").glob("*.md")),
    ROOT / "docs" / "index.html",
    ROOT / "index.html",
)


def test_focused_documentation_inventory_exists() -> None:
    expected = {
        ".nojekyll",
        "AGENT-HARNESS.md",
        "CONFIGURATION.md",
        "HOOKS.md",
        "README.md",
        "VERIFICATION.md",
        "WORKFLOW.md",
        "favicon.svg",
        "index.html",
    }
    actual = {path.name for path in (ROOT / "docs").iterdir() if path.is_file()}
    assert actual == expected


def test_complete_flow_is_named_where_users_enter() -> None:
    for document in FLOW_DOCS:
        text = document.read_text(encoding="utf-8")
        for name in CORE_SKILLS:
            assert f"/{name}" in text, f"Missing /{name} in {document.relative_to(ROOT)}"


def test_public_docs_do_not_advertise_removed_inventory() -> None:
    banned = (
        "curl -fsSL https://raw.githubusercontent.com/brolag/neural-open-code/main/install.sh",
        "learns and improves forever",
        "OpenCode that learns and improves",
        "/squad-init",
        "/pv-mesh",
        "codex plugin marketplace add",
        "scripts/setup-hooks.sh",
        "scripts/ralph-loop.sh",
        "~/Sites/neural-open-code",
    )
    for document in PUBLIC_DOCS:
        text = document.read_text(encoding="utf-8")
        for term in banned:
            assert term not in text, f"Stale {term!r} in {document.relative_to(ROOT)}"


def test_readme_documents_opencode_install_and_hook_review() -> None:
    text = (ROOT / "README.md").read_text(encoding="utf-8")
    assert "v1.18.31" in text
    assert '"plugin": ["./plugins/neural-open-code"]' in text
    assert "does not edit global OpenCode config" in text
    assert "does not trust hooks automatically" in text
    assert "archived/v1.9.0" in text


def test_github_page_has_required_sections_and_local_links() -> None:
    page = ROOT / "docs" / "index.html"
    text = page.read_text(encoding="utf-8")
    for section in ("workflow", "hooks", "install", "structure", "configuration"):
        assert f'id="{section}"' in text

    for target in re.findall(r'href="([^"#][^"]*)"', text):
        if target.startswith(("https://", "http://", "mailto:")):
            continue
        path = (page.parent / target).resolve()
        assert path.exists(), f"Broken local link {target}"

    assert "https://github.com/brolag/neural-open-code/blob/main/docs/WORKFLOW.md" in text
    assert "https://github.com/brolag/neural-open-code/blob/main/docs/CONFIGURATION.md" in text
    assert "https://github.com/brolag/neural-open-code/blob/main/docs/VERIFICATION.md" in text


def test_github_page_keeps_visible_gray_matrix_with_reduced_motion_fallback() -> None:
    for page in (ROOT / "docs" / "index.html", ROOT / "index.html"):
        text = page.read_text(encoding="utf-8")
        assert 'id="matrix-bg"' in text
        assert "--matrix: #f7f7f7" in text
        assert "drawStaticMatrix" in text
        assert "prefers-reduced-motion: reduce" in text
        assert "#matrix-bg { display: none; }" not in text


def test_configuration_is_advisory_and_current() -> None:
    text = (ROOT / "docs" / "CONFIGURATION.md").read_text(encoding="utf-8")
    assert not re.search(r'"model":\s*"', text)
    assert "does not install or edit OpenCode configuration except" in text
    assert "plugin" in text
    assert "skills.paths" in text
    assert "MCP" in text
