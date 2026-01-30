return {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yaml.docker-compose' },
  root_markers = { 'docker-compose.yml', 'docker-compose.yaml', '.git' },
}
