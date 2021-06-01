# Allocations

Each year, around the same time as [Rollover](./rollover.md), providers request
places for some courses. This is to limit the number of applicants limited as
they are generally over-supplied for that particular course. This process is
called 'Allocations'.

This document lists the changes needed to be made to the Publish codebase and
the timings for these changes.

## Before Allocations

- Update the setting `allocations_close_date` to reflect the date on which
  Allocations are closed.

## On Allocations open date

- Set feature flag `allocations: state: open`
- Set feature flag `show_next_cycle_allocation_recruitment_page: true` so that
  users are shown the interrupt screen when they first sign in.
- Increment the setting `allocation_cycle_year`
- Increment the setting `allocation_cycle_year` in the Teacher Training API.
  This should match what you've set here in Publish.

## On Allocations close date

- Set feature flag `allocations: state: closed`
- Set feature flag `show_next_cycle_allocation_recruitment_page: false` to turn
  off the interrupt page.

## On Allocations confirmed date

- Set feature flag `allocations: state: confirmed`
