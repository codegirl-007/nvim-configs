# Coding Style Guidelines

## General Principles

- Write clean, readable, and maintainable code
- Follow consistent naming conventions
- Use meaningful variable and function names
- Keep functions small and focused on a single responsibility
- Add comments for complex logic, but prefer self-documenting code

## Lua/Neovim Specific

- Use 2 spaces for indentation
- Prefer local variables over global ones
- Use snake_case for variable and function names
- Use PascalCase for module names
- Always use explicit returns in functions
- Prefer early returns to reduce nesting

## Code Organization

- Group related functionality together
- Separate configuration from implementation
- Use consistent file and directory structure
- Keep dependencies minimal and explicit

## Error Handling

- Handle errors gracefully
- Provide meaningful error messages
- Use proper error propagation patterns
- Log errors appropriately for debugging

## Performance

- Avoid premature optimization
- Profile before optimizing
- Cache expensive computations when appropriate
- Use appropriate data structures for the task
