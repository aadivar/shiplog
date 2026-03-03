#!/bin/bash
# detect-stack.sh — Auto-detect project tech stack
# Returns a JSON array of detected technologies

stack=()

# JavaScript / TypeScript ecosystem
if [ -f "package.json" ]; then
  deps=$(cat package.json 2>/dev/null)

  # Frameworks
  echo "$deps" | grep -q '"next"' && stack+=("Next.js")
  echo "$deps" | grep -q '"react"' && ! echo "$deps" | grep -q '"next"' && stack+=("React")
  echo "$deps" | grep -q '"vue"' && stack+=("Vue")
  echo "$deps" | grep -q '"nuxt"' && stack+=("Nuxt")
  echo "$deps" | grep -q '"svelte"' && stack+=("Svelte")
  echo "$deps" | grep -q '"@angular/core"' && stack+=("Angular")
  echo "$deps" | grep -q '"express"' && stack+=("Express")
  echo "$deps" | grep -q '"fastify"' && stack+=("Fastify")
  echo "$deps" | grep -q '"hono"' && stack+=("Hono")

  # Databases & ORMs
  echo "$deps" | grep -q '"prisma"' && stack+=("Prisma")
  echo "$deps" | grep -q '"drizzle-orm"' && stack+=("Drizzle")
  echo "$deps" | grep -q '"@supabase/supabase-js"' && stack+=("Supabase")
  echo "$deps" | grep -q '"firebase"' && stack+=("Firebase")
  echo "$deps" | grep -q '"mongoose"' && stack+=("MongoDB")

  # Styling
  echo "$deps" | grep -q '"tailwindcss"' && stack+=("Tailwind CSS")
  echo "$deps" | grep -q '"styled-components"' && stack+=("styled-components")

  # TypeScript
  echo "$deps" | grep -q '"typescript"' && stack+=("TypeScript")

  # Testing
  echo "$deps" | grep -q '"vitest"' && stack+=("Vitest")
  echo "$deps" | grep -q '"jest"' && stack+=("Jest")
  echo "$deps" | grep -q '"playwright"' && stack+=("Playwright")
fi

# Python
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  stack+=("Python")
  if [ -f "requirements.txt" ]; then
    grep -qi "django" requirements.txt && stack+=("Django")
    grep -qi "flask" requirements.txt && stack+=("Flask")
    grep -qi "fastapi" requirements.txt && stack+=("FastAPI")
  fi
  if [ -f "pyproject.toml" ]; then
    grep -qi "django" pyproject.toml && stack+=("Django")
    grep -qi "flask" pyproject.toml && stack+=("Flask")
    grep -qi "fastapi" pyproject.toml && stack+=("FastAPI")
  fi
fi

# Rust
if [ -f "Cargo.toml" ]; then
  stack+=("Rust")
  grep -q "actix" Cargo.toml && stack+=("Actix")
  grep -q "axum" Cargo.toml && stack+=("Axum")
  grep -q "tokio" Cargo.toml && stack+=("Tokio")
fi

# Go
if [ -f "go.mod" ]; then
  stack+=("Go")
  grep -q "gin-gonic" go.mod && stack+=("Gin")
  grep -q "gorilla/mux" go.mod && stack+=("Gorilla Mux")
fi

# Ruby
if [ -f "Gemfile" ]; then
  stack+=("Ruby")
  grep -q "rails" Gemfile && stack+=("Rails")
  grep -q "sinatra" Gemfile && stack+=("Sinatra")
fi

# Java / Kotlin
if [ -f "pom.xml" ]; then
  stack+=("Java")
  grep -q "spring" pom.xml && stack+=("Spring")
fi
if [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  [ -f "build.gradle.kts" ] && stack+=("Kotlin") || stack+=("Java")
  grep -q "spring" build.gradle* 2>/dev/null && stack+=("Spring")
fi

# Docker
[ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ] && stack+=("Docker")

# Output as JSON array
if [ ${#stack[@]} -eq 0 ]; then
  echo "[]"
else
  printf '['
  for i in "${!stack[@]}"; do
    printf '"%s"' "${stack[$i]}"
    [ $i -lt $((${#stack[@]} - 1)) ] && printf ', '
  done
  printf ']\n'
fi
