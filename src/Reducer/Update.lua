return function(state, action)
    state = state or {
        update = false
    }

    if action.type == "UPDATE" then
        return {update = not state.update}
    end

    return state
end