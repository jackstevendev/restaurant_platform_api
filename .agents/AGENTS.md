# AI Development Team — Restaurant Platform API

This file defines the global rules that apply to **all agents** working on this repository.

## Technical Stack

- **Framework**: Ruby on Rails 8 (API mode)
- **Language**: Ruby
- **Database**: PostgreSQL
- **Testing**: RSpec + FactoryBot
- **Containerization**: Docker + Kamal
- **Linting**: RuboCop

## General Conventions

1. All code must pass RuboCop without offenses (`bundle exec rubocop`)
2. All business logic goes in Services (`app/services/api/v1/`)
3. Controllers must be thin — orchestrate only, no business logic
4. Always write specs for new services and models
5. Never hardcode credentials; use `Rails.application.credentials` or ENV vars
6. Maintain backward compatibility in API v1

## Team Workflow

```
Architect → Developer → QA → Developer (fixes) → Reviewer → Human approval
```

All agents work on the same repository.
The human makes the final decisions.
