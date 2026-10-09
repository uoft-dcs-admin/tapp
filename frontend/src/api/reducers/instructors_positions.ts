import {
	FETCH_INSTRUCTORS_POSITIONS_SUCCESS,
	UPDATE_ONE_INSTRUCTOR_POSITION_SUCCESS,
} from "../constants";
import { RawInstructorPosition } from "../defs/types";
import { createReducer, HasPayload, upsertItem } from "./utils";

interface InstructorsPositionsState {
	_modelData: RawInstructorPosition[];
}

const initialState: InstructorsPositionsState = {
	_modelData: [],
};

export const instructorsPositionsReducer = createReducer(initialState, {
	[FETCH_INSTRUCTORS_POSITIONS_SUCCESS]: (
		state: InstructorsPositionsState,
		action: HasPayload<RawInstructorPosition[]>
	) => ({
		...state,
		_modelData: action.payload,
	}),
	[UPDATE_ONE_INSTRUCTOR_POSITION_SUCCESS]: (
		state: InstructorsPositionsState,
		action: HasPayload<RawInstructorPosition>
	) => ({
		...state,
		_modelData: upsertItem(state._modelData, action.payload),
	}),
});
