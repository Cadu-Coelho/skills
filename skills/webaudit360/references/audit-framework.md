# Framework WebAudit360

## Pilares

### Autenticidade visual

Avalie sinais de template genérico ou efeito clichê de IA, consistência da identidade, originalidade, direção de arte, coerência entre promessa e expressão visual e oportunidades de diferenciação sem prejudicar a usabilidade.

### Desenvolvimento e performance

Avalie estrutura e manutenção do código quando acessível, responsividade, compatibilidade, carregamento, Core Web Vitals quando mensuráveis, peso de ativos, cache, SEO técnico, tolerância a falhas e qualidade aparente das integrações.

### UI/UX e acessibilidade

Avalie hierarquia, arquitetura da informação, navegação, clareza dos estados, consistência de componentes, formulários, feedback, prevenção e recuperação de erros, teclado, foco, contraste, semântica e WCAG.

### Segurança, privacidade e conformidade

Avalie TLS, redirects, headers, CSP, cookies, autenticação e autorização observáveis, sessões, superfícies de entrada, uploads, exposição de dados, abuso, auditoria e transparência LGPD. Não confunda existência de textos legais com conformidade operacional comprovada.

### Banco de dados e infraestrutura

Somente afirme o que puder ser observado ou confirmado. Quando não houver acesso interno, apresente hipóteses explicitamente condicionais sobre modelagem, índices, concorrência, cache, resiliência, backup, restauração, observabilidade e custo.

### Marketing, growth e conversão

Avalie proposta de valor, adequação ao segmento, copy, CTAs, prova social, confiança, jornada e funil, captura e mensuração de leads, SEO de conteúdo e atritos de conversão.

### Dimensões ocultas

Inclua de 3 a 5 aspectos relevantes que não tenham sido pedidos, como observabilidade, recuperação de desastre, dependência de fornecedor, governança de conteúdo, acessibilidade legal, custo por usuário ou requisição, reputação de e-mail, internacionalização ou operação de incidentes.

## Classificação dos achados

Para cada achado relevante, informe:

- Categoria: bug impeditivo, bug normal, risco, melhoria ou evolução/MVP.
- Severidade: crítica, alta, média ou baixa.
- Evidência: URL/tela/fluxo, medição, código/configuração, ou inferência declarada.
- Impacto: usuário, negócio, segurança, conformidade ou operação.
- Esforço: baixo, médio ou alto, com dependências quando existirem.
- Recomendação e critério de aceite verificável.

Bug impeditivo significa que uma função essencial prometida não pode ser concluída com segurança ou causa perda, corrupção ou exposição relevante. Ausência de uma evolução ainda não prometida não é bug.

## Estrutura do relatório

### 1. Resumo executivo e nota geral

- Score global de 0 a 100, com base resumida.
- Índice de autenticidade visual versus genericidade.
- Principal ponto forte e maior risco ou gargalo em duas frases.
- Escopo efetivamente testado e limitações.

### 2. Perfil visual: autenticidade versus clichê

- Sinais de genericidade identificados.
- Elementos de originalidade e diferenciação.
- Recomendações objetivas para elevar a identidade sem sacrificar clareza.

### 3. Análise técnica por pilar

Para Web Dev/performance, UI/UX/acessibilidade, segurança/privacidade, BD/infra e marketing/CRO:

- Pontos fortes confirmados.
- Gargalos e riscos, com nível de evidência.
- Recomendações e critérios de aceite.

### 4. Matriz de dimensões ocultas

Apresente 3 a 5 dimensões, seu diagnóstico, impacto no negócio e prioridade.

### 5. Plano priorizado

- Fase 0: bloqueadores e riscos críticos, se houver.
- Fase 1: quick wins de alto impacto e baixo esforço.
- Fase 2: melhorias estruturais de médio prazo.
- Fase 3: refinamento e diferenciação de longo prazo.

Inclua dependências, estimativa qualitativa de esforço e critérios de aceite. Quando o usuário estiver acumulando escopo, apresente também o agregado atualizado conforme a convenção do projeto.

## Fontes de referência

Priorize fontes oficiais e atuais: OWASP, W3C/WAI e WCAG, web.dev/Chrome Developers para Core Web Vitals, MDN, documentação oficial dos provedores usados e fontes oficiais brasileiras para LGPD. Cite o link próximo da afirmação quando houver consulta externa.

## Origem

Framework adaptado de um prompt de auditoria de sites. A adaptação mantém os pilares e o formato do relatório e acrescenta rastreabilidade de evidências, classificação de backlog, limites de autorização e prevenção de afirmações não comprovadas.
