# 7S-05: SECURITY - simple_markdown


**Date**: 2026-01-23

**BACKWASH** | Generated: 2026-01-23 | Library: simple_markdown

## Security Model

### Trust Boundary
- Input: Untrusted Markdown content
- Output: HTML (potentially rendered in browser)
- Context: Content processing library

### Threat Assessment

| Threat | Risk | Mitigation |
|--------|------|------------|
| XSS via HTML injection | High | HTML entity escaping |
| JavaScript in URLs | Medium | No URL validation (caller responsibility) |
| Malicious links | Medium | Links preserved as-is |
| Resource exhaustion | Low | No recursion limits |
| Path traversal in images | Low | URL passed through as-is |

## HTML Escaping

### Escaped Characters
- `&` -> `&amp;`
- `<` -> `&lt;`
- `>` -> `&gt;`
- `"` -> `&quot;`

### Escaping Locations
- All text content
- Code blocks (no processing)
- Attribute values

### Not Escaped (By Design)
- URLs in links and images
- Language hints in code blocks

## Input Validation

### Markdown Input
- No size limits (caller responsibility)
- Handles malformed Markdown gracefully
- No crash on unexpected input

### File Input
- Path validation by Eiffel file library
- File existence check before reading
- Returns empty string on failure

## Recommendations for Callers

1. **Sanitize URLs** - Validate link/image URLs before rendering
2. **Content Security Policy** - Use CSP headers when serving HTML
3. **Size Limits** - Impose input size limits at application level
4. **Trusted Content Only** - Don't process untrusted user content without review

## Known Security Considerations

1. **No URL Sanitization**
   - Links and images pass URLs through unchanged
   - Caller must sanitize if needed

2. **No HTML Tag Stripping**
   - Raw HTML in Markdown is escaped, not stripped
   - This is the safe default
