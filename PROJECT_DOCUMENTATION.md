name: RaceDay Part 1 Validation

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  validate-raceday:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Check RaceDay folders
        run: |
          test -d docs
          test -d .github/workflows

      - name: Check RaceDay Part 1 files
        run: |
          test -f docs/RaceDay_ERD.pdf
          test -f docs/RaceDay_API_Endpoint_Plan.md
          test -f docs/RaceDay_Database.sql
          test -f docs/RaceDay_ERD_Relationships.md

      - name: Check SQL database script
        run: |
          test -s docs/RaceDay_Database.sql

      - name: Check API endpoint plan
        run: |
          test -s docs/RaceDay_API_Endpoint_Plan.md

      - name: Check ERD
        run: |
          test -s docs/RaceDay_ERD.pdf

      - name: Check ERD relationships
        run: |
          test -s docs/RaceDay_ERD_Relationships.md

      - name: RaceDay Part 1 validation complete
        run: |
          echo "========================================="
          echo "RaceDay Part 1 validation successful!"
          echo "ERD: FOUND"
          echo "API Endpoint Plan: FOUND"
          echo "SQL Script: FOUND"
          echo "ERD Relationships: FOUND"
          echo "========================================="
