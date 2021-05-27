# Rollover

Each year we close the current cycle's courses and open the new cycle in a
process we call 'Rollover'.

This involves copying existing providers and courses to new records to allow the
providers to update any details and then switching the API over to a new
'recruitment cycle' which in turn releases the new courses on Find & Apply, when
the course is 'published'. We make copies of the providers and courses because
during Rollover the current cycle is still open for applications. As such, we
can't make any changes to existing courses.

This document lists the changes needed to be made to the Publish codebase and
the timings for these changes. There is separate documentation for TTAPI
[here](https://github.com/DFE-Digital/teacher-training-api/blob/master/docs/rollover.md).

## Testing the Rollover process

This should happen every year in good time to allow for any code
updates/refactoring work.

1. Ensure that **testing environments** are set up for TTAPI and Publish.
2. Begin a 'test' Rollover (see **'On Rollover launch date'**)
3. **Review key user journeys** whilst the environment is in Rollover.
4. End the 'test' Rollover (see **'On Rollover end date'**)
5. **Review key user journeys** now that Rollover has ended.
6. **Reverse the Rollover** if further testing needed.
7. **Update this document** with any missing steps/changes identified.

## Before Rollover

1. Create a **Rollover PR** including the following code changes:
    - Set feature flag `can_edit_current_and_next_cycles: true`
    - Set feature flag `has_current_cycle_started?: false`
    - If allocations still ongoing, set feature flag
      `show_next_cycle_allocation_recruitment_page: true`
    - [TBC - this may be refactored] Create a new state for users
      `:accepted_rollover_#{year}`. Ensure users are transitioned to this new
      state when they accept Rollover.
    - Any hardcoded copy changes
2. Create **new Google forms** for adding PE courses for the next cycle

## On Rollover launch date

1. Complete the steps on TTAPI. You will need to have run the Rollover rake
  tasks before merging the changes to Publish.
2. Merge the Rollover PR

## During Rollover

1. Create an **End Rollover PR** including the following code changes:
    - Increment setting `current_cycle`
    - Increment the route constraint in `resources :recruitment_cycles`
    - Set feature flag `can_edit_current_and_next_cycles: false`
    - Replace `google_forms: current_cycle:` settings with those in
      `google_forms: next_cycle:`
    - Add new Google forms to `google_forms: next_cycle:`
    - Any hardcoded copy changes

## On Allocations end date

Allocations may have ended before Rollover began. In this case, there is nothing
to do.

Else, set feature flag `show_next_cycle_allocation_recruitment_page: false`

## On Rollover end date

1. Complete the steps on TTAPI
1. Merge the End Rollover PR

## On recruitment cycle start date

Set feature flag `has_current_cycle_started: true`
