---
name: webaudit360
description: Auditar sites de forma multidisciplinar em arquitetura web, desempenho, UI/UX, acessibilidade, segurança, privacidade, infraestrutura, SEO, conversão e autenticidade visual. Use quando o usuário pedir auditoria, diagnóstico abrangente, parecer de mercado ou plano priorizado de melhorias para um site; não use para uma correção pontual já delimitada.
---

# WebAudit360

Produza uma auditoria executiva e técnica baseada em evidências observáveis. Leia [references/audit-framework.md](references/audit-framework.md) integralmente antes de executar a auditoria.

## Contexto mínimo

- Confirme a URL e o foco de mercado. Se o foco ainda não estiver disponível no pedido nem no contexto confiável do projeto, faça somente uma pergunta objetiva antes da auditoria completa.
- Se o projeto já documenta o negócio (no `CLAUDE.md` ou em `.claude/rules/`: segmento, público, serviços), adote esse contexto por padrão em vez de perguntar.
- Confirme o ambiente analisado: produção, homologação ou ambos.

## Evidência e limites

- Diferencie claramente: observado, medido, confirmado no código/configuração, inferido e não verificável.
- Não atribua nota positiva ou negativa a banco, infraestrutura interna, LGPD operacional ou controles administrativos sem evidência proporcional.
- Quando houver acesso autorizado ao repositório, complemente a navegação com inspeção de código, configurações e testes somente leitura.
- Para informações atuais de normas, segurança, legislação ou referências oficiais, valide em fontes primárias atuais quando a precisão exigir.
- Auditoria não autoriza alteração, publicação, cadastro externo nem correção. Entregue o diagnóstico e aguarde solicitação explícita para mudanças.
- Nunca exponha segredos, tokens, cookies, senhas, dados pessoais ou detalhes exploráveis de vulnerabilidades em produção. Descreva riscos de forma responsável.

## Execução

1. Defina escopo, foco de mercado, ambiente e nível de acesso disponível.
2. Inspecione os fluxos públicos e, quando autorizado, os fluxos autenticados relevantes, incluindo desktop, mobile, teclado e estados de erro, vazio e carregamento.
3. Colete evidências técnicas proporcionais: TLS e redirects, headers, cookies observáveis, CSP, formulários, rotas, metadados/SEO, acessibilidade, performance e integrações visíveis.
4. Analise autenticidade visual, Web Dev e performance, UI/UX e WCAG, segurança e privacidade, banco/infra quando houver evidências, e marketing/CRO.
5. Inclua de 3 a 5 dimensões ocultas relevantes ao modelo de negócio.
6. Classifique cada achado por severidade, impacto, evidência e esforço. Separe bug impeditivo, bug normal, risco, melhoria e evolução/MVP.
7. Priorize um roadmap executável, com critérios de aceite e dependências. Não misture fatos com recomendações.

## Entrega

- Use a estrutura de relatório definida em `references/audit-framework.md`.
- Informe o que foi efetivamente testado e o que ficou fora do alcance.
- Sempre que houver score, explique resumidamente a base da pontuação e evite falsa precisão.
- Se o projeto tiver backlog, registre itens nele apenas quando o usuário pedir a inclusão ou aprovar a recomendação.
