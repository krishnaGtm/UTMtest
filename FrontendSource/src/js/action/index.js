// actions

/* export const sidemenuToggle = (status) => ({
    type: "ASSIGN_SIDEMEN",
    status
}) */

export const setPageTitle = title => ({
  type: 'SET_PAGETITLE',
  title
});

export function sidemenuToggle() {
  return {
    type: 'TOGGLE_SIDEMENU'
  };
}
export function sidemenuClose() {
  return {
    type: 'ASSIGN_SIDEMENU',
    status: false
  };
}
/*

export function clearFilter() {
    return {
        type: "FILTER_CLEAR"
    }
}

export function typeBulk(data) {
    return {
        type: 'TYPE_BULK_ADD',
        data: data
    }
}

export function markerBlank() {
    return {
        type: 'MARKER_BLANK'
    }
}
export function markerList(data) {
    return {
        type: 'MARKER_BULK_ADD',
        data: data
    }
} */
