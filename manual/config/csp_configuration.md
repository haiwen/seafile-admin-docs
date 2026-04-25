# Configure CSP for Seafile

This document describes how to add `Content-Security-Policy` response header for a Seafile site to increase security.


## Recommended CSP policy

The following policy can be used as a baseline for Seafile sites integrated with SeaDoc and OnlyOffice:

```http
Content-Security-Policy: default-src 'self'; base-uri 'self'; object-src 'none'; form-action 'self'; frame-ancestors 'self'; img-src 'self' data: blob:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: https://ONLYOFFICE_ORIGIN; connect-src 'self' https://ONLYOFFICE_ORIGIN wss://SEAFILE_DOMAIN; frame-src 'self' blob: https://ONLYOFFICE_ORIGIN; worker-src 'self' blob:
```

Replace the following values:

```text
SEAFILE_DOMAIN       The Seafile site domain, for example seafile.example.com
ONLYOFFICE_ORIGIN    The real OnlyOffice origin, for example seafile.example.com:6233 or office.example.com
```


!!! warning
    Use the real OnlyOffice origin configured in `ONLYOFFICE_APIJS_URL`. Do not copy `:6233` if your OnlyOffice service uses standard 80 or 443 port.

## CSP directive reference

| Directive | Value | Purpose |
| --- | --- | --- |
| `default-src` | `'self'` | Allows same-origin resources by default and blocks unknown external resources. |
| `base-uri` | `'self'` | Restricts the `<base>` tag to the same origin and prevents malicious rewriting of relative links. |
| `object-src` | `'none'` | Blocks high-risk plugin objects such as `object`, `embed` and `applet`. |
| `form-action` | `'self'` | Allows forms to be submitted only to the Seafile site. |
| `frame-ancestors` | `'self'` | Prevents other sites from embedding Seafile pages in iframes and reduces clickjacking risk. |
| `img-src` | `'self' data: blob:` | Allows same-origin images, base64 images and browser temporary images. This keeps avatars, thumbnails and image/PDF previews working. |
| `style-src` | `'self' 'unsafe-inline'` | Allows same-origin CSS and inline styles required by Seafile, SeaDoc and OnlyOffice frontend components. |
| `script-src` | `'self' 'unsafe-inline' 'unsafe-eval' blob: https://ONLYOFFICE_ORIGIN` | Allows Seafile scripts, required inline/dynamic scripts, blob scripts and the OnlyOffice `api.js`. |
| `connect-src` | `'self' https://ONLYOFFICE_ORIGIN wss://SEAFILE_DOMAIN` | Allows Seafile API requests, OnlyOffice requests and SeaDoc/WebSocket connections. |
| `frame-src` | `'self' blob: https://ONLYOFFICE_ORIGIN` | Allows Seafile pages to embed same-origin pages, blob pages and the OnlyOffice editor iframe. |
| `worker-src` | `'self' blob:` | Allows Web Workers used by PDF preview, document editors and frontend async processing. |

## Configure CSP with Caddy

This method applies to the official Seafile Docker deployment when Caddy is used as the reverse proxy.

Add the following label under `services.seafile.labels` in `seafile-server.yml`:

```yaml
services:
  seafile:
    labels:
      caddy.header.Content-Security-Policy: "\"default-src 'self'; base-uri 'self'; object-src 'none'; form-action 'self'; frame-ancestors 'self'; img-src 'self' data: blob:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: https://seafile.example.com:6233; connect-src 'self' https://seafile.example.com:6233 wss://seafile.example.com; frame-src 'self' blob: https://seafile.example.com:6233; worker-src 'self' blob:\""
```

Replace the example values with your real URL.

Restart the containers:

```sh
docker compose down
docker compose up -d
```

Verify the response header:

```sh
DOMAIN=seafile.example.com

curl -sIk https://$DOMAIN/ | grep -i content-security-policy
curl -sIk https://$DOMAIN/accounts/login/ | grep -i content-security-policy
curl -sIk https://$DOMAIN/sdoc-server/ | grep -i content-security-policy
curl -sIk https://$DOMAIN/seafhttp/ | grep -i content-security-policy

docker exec seafile-caddy sh -lc "grep -in 'Content-Security-Policy' /config/caddy/Caddyfile.autosave"
```

The expected output should contain:

```http
content-security-policy: default-src 'self'; ...
```

## Configure CSP with Nginx

This method applies when Nginx is used as the reverse proxy in front of Seafile.

Add the following header in the corresponding `server` block:

```nginx
server {
    listen 443 ssl http2;
    server_name seafile.example.com;

    add_header Content-Security-Policy "default-src 'self'; base-uri 'self'; object-src 'none'; form-action 'self'; frame-ancestors 'self'; img-src 'self' data: blob:; style-src 'self' 'unsafe-inline'; script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: https://seafile.example.com:6233; connect-src 'self' https://seafile.example.com:6233 wss://seafile.example.com; frame-src 'self' blob: https://seafile.example.com:6233; worker-src 'self' blob:" always;

    # Other Seafile reverse proxy settings.
}
```

Check and reload Nginx:

```sh
nginx -t
systemctl reload nginx
```

Verify the response header:

```sh
curl -sIk https://seafile.example.com/ | grep -i content-security-policy
```

The expected output should contain:

```http
content-security-policy: default-src 'self'; ...
```

## Test with Report-Only

Before enabling the enforcing policy, you can test with Report-Only mode:

```http
Content-Security-Policy-Report-Only: ...
```

For Caddy, temporarily change:

```yaml
caddy.header.Content-Security-Policy
```

to:

```yaml
caddy.header.Content-Security-Policy-Report-Only
```

For Nginx, temporarily change:

```nginx
add_header Content-Security-Policy "..." always;
```

to:

```nginx
add_header Content-Security-Policy-Report-Only "..." always;
```

After testing that Seafile works normally, switch back to the enforcing `Content-Security-Policy` header.

!!! warning
    Report-Only mode does not enforce the policy. It is useful for testing, but it may not satisfy security scan requirements.

## Functional test checklist

After configuring CSP, test the following features:

```text
Login and logout
File upload and download
PDF and image preview
Creating, opening, editing and saving SeaDoc files
Opening, editing and saving docx / xlsx / pptx files with OnlyOffice
Share link access
```

Also check the browser console for CSP violations:

```text
Refused to load ... because it violates the following Content Security Policy directive ...
```

If a CSP violation appears, check `violated-directive` and `blocked-uri` in the browser developer tools, then add the required source to the corresponding CSP directive.
