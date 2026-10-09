import {
	FETCH_INSTRUCTORS_POSITIONS_SUCCESS,
	UPDATE_ONE_INSTRUCTOR_POSITION_SUCCESS,
} from "../constants";
import { fetchError, upsertError } from "./errors";
import { actionFactory, isSameSession, validatedApiDispatcher } from "./utils";
import { apiGET, apiPATCH } from "../../libs/api-utils";
import { RawInstructorPosition } from "../defs/types";
import { activeSessionSelector } from "./sessions";

export const fetchInstructorsPositionsSuccess = actionFactory<
	RawInstructorPosition[]
>(FETCH_INSTRUCTORS_POSITIONS_SUCCESS);
const updateOneInstructorPositionSuccess = actionFactory<RawInstructorPosition>(
	UPDATE_ONE_INSTRUCTOR_POSITION_SUCCESS
);

export const fetchInstructorsPositions = validatedApiDispatcher<
	RawInstructorPosition[],
	[]
>({
	name: "fetchInstructorsPositions",
	description: "Fetch instructor-position subscriptions",
	onErrorDispatch: (e) => fetchError(e.toString()),
	dispatcher: () => async (dispatch, getState) => {
		const activeSession = activeSessionSelector(getState());
		if (activeSession == null) {
			throw new Error(
				"Cannot fetch InstructorPositions without an active session"
			);
		}

		const { id: activeSessionId } = activeSession;
		const data = (await apiGET(
			`/instructor/sessions/${activeSessionId}/instructors_positions`
		)) as RawInstructorPosition[];
		if (isSameSession(activeSessionId, getState)) {
			dispatch(fetchInstructorsPositionsSuccess(data));
		}
		return data;
	},
});

export const updateInstructorPosition = validatedApiDispatcher<
	RawInstructorPosition,
	[Pick<RawInstructorPosition, "id" | "is_subscribed">]
>({
	name: "updateInstructorPosition",
	description: "Update an instructor-position subscription",
	onErrorDispatch: (e) => upsertError(e.toString()),
	dispatcher: (payload) => async (dispatch) => {
		const data = (await apiPATCH(
			`/instructor/instructors_positions/${payload.id}`,
			{ is_subscribed: payload.is_subscribed }
		)) as RawInstructorPosition;
		dispatch(updateOneInstructorPositionSuccess(data));
		return data;
	},
});
