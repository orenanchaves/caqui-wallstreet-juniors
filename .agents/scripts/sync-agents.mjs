// Gera (ou valida com --check) os adapters dos agentes a partir de .agents/manifest.json.
// Claude Code: .agents/agents/<slug>.md (lido via symlink .claude -> .agents)
// Codex:       .codex/agents/<slug>.toml
import fs from 'node:fs';
import path from 'node:path';

const root = path.resolve(import.meta.dirname, '../..');
const manifest = JSON.parse(fs.readFileSync(path.join(root, '.agents/manifest.json'), 'utf8'));
const check = process.argv.includes('--check');
const seen = new Set();
const outputs = new Map();

if (manifest.schemaVersion !== 1 || !Array.isArray(manifest.agents)) throw new Error('Manifesto inválido.');
const squad = manifest.squad;

for (const agent of manifest.agents) {
  if (seen.has(agent.id)) throw new Error(`ID duplicado: ${agent.id}`);
  seen.add(agent.id);
  if (!fs.existsSync(path.join(root, `.agents/skills/${agent.skill}/SKILL.md`))) throw new Error(`Skill inexistente: ${agent.skill}`);
  const rules = `Leia AGENTS.md, SPEC.md e .agents/skills/${agent.skill}/SKILL.md antes de agir. Siga o briefing da sessão principal. Antes de editar, rode git status --short e git branch --show-current; não edite em main. Não invente evidências, não exponha segredos e não leia nem imprima .env. Ao terminar, entregue: arquivos alterados, comandos executados com resultado, testes, riscos e pendências.`;
  outputs.set(`.agents/agents/${agent.slug}.md`, `---\nname: ${agent.id}\ndescription: ${agent.description}\ntools: Read, Grep, Glob, Bash, Edit, Write\n---\n\n# ${agent.title}\n\nVocê é ${agent.title} da ${squad}.\n\n${rules}\n`);
  outputs.set(`.codex/agents/${agent.slug}.toml`, `name = "${agent.id}"\ndescription = "${agent.description}"\n\ndeveloper_instructions = """\nVocê é ${agent.title} da ${squad}.\n${rules}\n"""\n`);
}

const rows = manifest.agents.map(a => `| \`${a.id}\` | ${a.title} | \`${a.skill}\` |`).join('\n');
outputs.set('.agents/agents.md', `# Catálogo de agentes\n\n> Gerado de \`.agents/manifest.json\`. Não edite manualmente.\n\n| ID | Especialidade | Skill |\n|---|---|---|\n${rows}\n`);

let stale = false;
for (const [relative, expected] of outputs) {
  const file = path.join(root, relative);
  if (check) {
    if (!fs.existsSync(file) || fs.readFileSync(file, 'utf8') !== expected) { console.error(`Adapter desatualizado: ${relative}`); stale = true; }
  } else {
    fs.mkdirSync(path.dirname(file), { recursive: true });
    fs.writeFileSync(file, expected);
  }
}
if (stale) process.exit(1);
console.log(check ? `${outputs.size} adapters válidos.` : `${outputs.size} adapters sincronizados.`);
