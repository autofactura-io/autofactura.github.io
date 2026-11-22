# Autofactura portal changes

## Startup and shared dependencies

The login renders outside the authenticated shell. Autofactura mounts the
shell after authorization and uses the session state to return to the access
screen after logout. The shared Widgets shell supplies sitemap behavior and
the date range component comes from `widgets/daterange.xhtml`.

| Dependency | Pinned revision |
| --- | --- |
| XOver | `19de670` |
| Widgets | `6073228` |

The submodule revisions pin both dependencies in a Git checkout. Development
IIS serves `/xover/` and `/widgets/` through virtual directories. Verify
that those directories serve the pinned revisions when testing locally.

## Global Invoice

The `#facturas` store reads `autofactura.portalTickets`. The initial
request uses the current period defined by the backend. Requests send
`X-Page-Index` and `X-Page-Size` as HTTP headers. The XML query carries the
server filters. The response's page metadata and total count drive the
counter and Previous and Next controls.

The Client filter lists authorized clients and updates the available
branches. The panel groups client and ticket filters. The Apply button
commits pending edits after three idle seconds. Pointer movement resets
the countdown. Enter applies immediately, and both the click and automatic
paths use the same button feedback.

A ticket's folio opens its complete detail, including products, payment
methods and amounts. The modal keeps its title, close button and totals
visible while the body scrolls. Selection lives in the XML store, including
selected records from other pages. The pre-invoice reads that selection.
The folio view in the Concentrator also exposes selection and pre-invoice
actions.

## CFDI Mass Download

The consulted-date range uses the shared date widget with Flatpickr enabled.
Date range and the report's other filters are applied through the report
action. The report opens invoices through the CFDI viewer and displays
human-readable SAT status labels.

## Development verification

Opened Factura Global with the pinned XOver and Widgets versions, confirmed
that the shared menu opens and displays its entries, and opened and closed a
ticket with the totals footer visible. Navigated to page 2 and back to page 1,
checking that both pages reported the same server total.
