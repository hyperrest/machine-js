define = require('amdefine')(module)  if typeof define isnt 'function'
define [
  'know-your-http-well'
], (
  httpWell
) ->
  "use strict"

  statusWell = httpWell.statusPhrasesToCodes

  # Precondition
  {
    # Create
    block_missing_precondition:
      _onEnter: () -> @transition 'missing_has_precondition'

    missing_has_precondition:
      _onEnter: () -> @handle @resource.missing_has_precondition()
      true:     'block_retrieve_moved'
      false:    () ->
        @operation.response.status or= statusWell.PRECONDITION_FAILED
        'block_response_alternative'

    # Process
    block_precondition:
      _onEnter: () -> @transition 'has_if_match'

    has_if_match:
      _onEnter: () -> @handle @resource.has_if_match()
      true:     'if_match_matches'
      false:    'has_if_unmodified_since'

    if_match_matches:
      _onEnter: () -> @handle @resource.if_match_matches()
      true:     'has_if_unmodified_since'
      false:    () ->
        @operation.response.status or= statusWell.PRECONDITION_FAILED
        'block_response_alternative'

    has_if_unmodified_since:
      _onEnter: () -> @handle @resource.has_if_unmodified_since()
      true:     'if_unmodified_since_matches'
      false:    'has_if_none_match'

    if_unmodified_since_matches:
      _onEnter: () -> @handle @resource.if_unmodified_since_matches()
      false:    'has_if_unmodified_since'
      true:     () ->
        @operation.response.status or= statusWell.PRECONDITION_FAILED
        'block_response_alternative'

    has_if_none_match:
      _onEnter: () -> @handle @resource.has_if_none_match()
      true:     'if_none_match_matches'
      false:    'has_if_modified_since'

    if_none_match_matches:
      _onEnter: () -> @handle @resource.if_none_match_matches()
      false:    'has_if_modified_since'
      true:     'is_precondition_safe'

    has_if_modified_since:
      _onEnter: () -> @handle @resource.has_if_modified_since()
      false:    'block_process'
      true:     'if_modified_since_matches'

    if_modified_since_matches:
      _onEnter: () -> @handle @resource.if_modified_since_matches()
      true:     'block_process'
      false:    'is_precondition_safe'

    is_precondition_safe:
      _onEnter: () -> @handle @resource.is_precondition_safe()
      true:     () ->
        @operation.response.status or= statusWell.NOT_MODIFIED
        'last'
      false:    () ->
        @operation.response.status or= statusWell.PRECONDITION_FAILED
        'block_response_alternative'
  }
