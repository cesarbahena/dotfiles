# layout.json Guide

## Purpose

Defines UI structure to prevent emergent design.

## DSL

``` json
{
  "type": "screen",
  "name": "Login",
  "layout": "column",
  "children": [
    { "type": "input", "name": "email" },
    { "type": "button", "name": "login" }
  ]
}
```

## Rules

-   Must reflect flow.mmd
-   No styling
-   Only structure and hierarchy
-   Components must be named
-   Layout must be explicit
-   Every clickable element must appear in flow
