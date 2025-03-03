<div align="center">
  <picture>
    <img alt="Lennarb" src="logo/lennarb.svg" width="250">
  </picture>

---

Um framework web leve, rápido e modular para Ruby baseado em Rack. **Lennarb** suporta Ruby (MRI) 3.4+

[![Test](https://github.com/aristotelesbr/lennarb/actions/workflows/test.yaml/badge.svg)](https://github.com/aristotelesbr/lennarb/actions/workflows/test.yaml)
[![Gem](https://img.shields.io/gem/v/lennarb.svg)](https://rubygems.org/gems/lennarb)
[![Gem](https://img.shields.io/gem/dt/lennarb.svg)](https://rubygems.org/gems/lennarb)
[![MIT License](https://img.shields.io/:License-MIT-blue.svg)](https://tldrlegal.com/license/mit-license)

</div>

## Índice

- [Características](#características)
- [Instalação](#instalação)
- [Início Rápido](#início-rápido)
- [Performance](#performance)
- [Documentação](#documentação)
- [Contribuindo](#contribuindo)
- [Licença](#licença)

## Características

- Arquitetura leve e modular
- Sistema de roteamento de alta performance
- API simples e intuitiva
- Suporte para middleware
- Opções de configuração flexíveis
- Duas opções de implementação:
  - `Lennarb::App`: Abordagem minimalista para controle completo
  - `Lennarb::Application`: Versão estendida com componentes comuns

## Opções de Implementação

Lennarb oferece duas abordagens de implementação para atender diferentes necessidades:

- **Lennarb::App**: Abordagem minimalista para controle completo
- **Lennarb::Application**: Versão estendida com componentes comuns

Consulte a [documentação](https://aristotelesbr.github.io/lennarb/guides/getting-started/index) para detalhes sobre cada implementação.

## Instalação

Adicione esta linha ao Gemfile da sua aplicação:

```ruby
gem 'lennarb'
```

Ou instale diretamente:

```bash
gem install lennarb
```

## Guia Rápido

```ruby
require "lennarb"

app = Lennarb::App.new do
  configure do
    mandary :database_url, string
    optional :port, integer, 9292
    optional :env, string, "development"
  end

  routes do
    get("/") do |req, res|
      res.html("<h1>Bem-vindo ao Lennarb!</h1>")
    end

    get("/hello/:name") do |req, res|
      name = req.params[:name]
      res.html("Olá, #{name}!")
    end
  end
end

app.initialize!
run app  # Em config.ru
```

Inicie com: `rackup`

## Performance

Lennarb é projetado para alta performance:

![RPS](https://raw.githubusercontent.com/aristotelesbr/lennarb/main/benchmark/rps.png)

| Posição | Aplicação  | 10 RPS     | 100 RPS    | 1.000 RPS | 10.000 RPS |
| ------- | ---------- | ---------- | ---------- | --------- | ---------- |
| 1       | Lenna      | 126.252,36 | 108.086,55 | 87.111,91 | 68.460,64  |
| 2       | Roda       | 123.360,37 | 88.380,56  | 66.990,77 | 48.108,29  |
| 3       | Syro       | 114.105,38 | 80.909,39  | 61.415,86 | 46.639,81  |
| 4       | Hanami-API | 68.089,18  | 52.851,88  | 40.801,78 | 27.996,00  |

Veja todos os [gráficos de benchmark](https://github.com/aristotelesbr/lennarb/blob/main/benchmark)

## Documentação

- [Primeiros Passos](https://aristotelesbr.github.io/lennarb/guides/getting-started/index) - Configuração e primeiros passos
- [Performance](https://aristotelesbr.github.io/lennarb/guides/performance/index.html) - Benchmarks e otimização
- [Response](https://aristotelesbr.github.io/lennarb/guides/response/index.html) - Tratamento de respostas
- [Request](https://aristotelesbr.github.io/lennarb/guides/request/index.html) - Tratamento de requisições

## Funcionalidades Principais

```ruby
# Diferentes tipos de resposta
res.html("<h1>Olá Mundo</h1>")
res.json("{\"mensagem\": \"Olá Mundo\"}")
res.text("Resposta em texto simples")

# Parâmetros de rota
get("/usuarios/:id") do |req, res|
  user_id = req.params[:id]
  res.json("{\"id\": #{user_id}}")
end

# Redirecionamentos
res.redirect("/nova-localizacao")
```

Para mais exemplos e documentação completa, consulte:
[Documentação Completa do Lennarb](https://aristotelesbr.github.io/lennarb/guides/getting-started/index)

## Contribuindo

1. Faça um fork do repositório
2. Crie sua branch de feature (`git checkout -b feature/recurso-incrivel`)
3. Commit suas alterações (`git commit -am 'Adiciona recurso incrível'`)
4. Push para a branch (`git push origin feature/recurso-incrivel`)
5. Abra um Pull Request

Este projeto utiliza o [Developer Certificate of Origin](https://developercertificate.org/) e é regido pelo [Contributor Covenant](https://www.contributor-covenant.org/).

## Licença

Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

