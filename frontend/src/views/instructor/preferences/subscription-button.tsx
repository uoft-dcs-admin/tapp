import React from "react";
import NotificationsActiveIcon from "@mui/icons-material/NotificationsActive";
import NotificationsNoneIcon from "@mui/icons-material/NotificationsNone";
import { Button, Tooltip } from "@mui/material";
import { useSelector } from "react-redux";

import { activeUserSelector } from "../../../api/actions";
import { updateInstructorPosition } from "../../../api/actions/instructors_positions";
import { rawSelector } from "../../../api/selectors/raw-selectors";
import { useThunkDispatch } from "../../../libs/thunk-dispatch";
import { activePositionSelector } from "../store/actions";

export function SubscriptionButton() {
    const activeUser = useSelector(activeUserSelector);
    const activePosition = useSelector(activePositionSelector);
    const instructorsPositions = useSelector(rawSelector.instructorsPositions);
    const dispatch = useThunkDispatch();
    const [isUpdating, setIsUpdating] = React.useState(false);

    const activeUtorid = "utorid" in activeUser ? activeUser.utorid : null;
    const isPositionInstructor = activePosition?.instructors.some(
        (instructor) => instructor.utorid === activeUtorid
    );
    const instructorPosition = instructorsPositions.find(
        (item) => item.position_id === activePosition?.id
    );

    if (!isPositionInstructor || !instructorPosition) {
        return null;
    }

    const isSubscribed = instructorPosition.is_subscribed;
    const tooltip = isSubscribed
        ? "You are currently on the mailing list for TA offer activity for this position. " +
            "Click to unsubscribe if you wish to no longer receive the emails."
        : "You are not currently on the mailing list for TA offer activity for this position. " +
            "Click to subscribe and receive a daily email summary of offer activity. " + 
            "Emails will be sent only on days for which there is offer activity to report.";

    const toggleSubscription = async () => {
        setIsUpdating(true);
        try {
            await dispatch(
                updateInstructorPosition({
                    id: instructorPosition.id,
                    is_subscribed: !isSubscribed,
                })
            );
        } finally {
            setIsUpdating(false);
        }
    };

    return (
        <Tooltip title={tooltip}>
            <span>
                <Button
                    color="success"
                    variant={isSubscribed ? "contained" : "outlined"}
                    startIcon={
                        isSubscribed ? (
                            <NotificationsActiveIcon />
                        ) : (
                            <NotificationsNoneIcon />
                        )
                    }
                    disabled={isUpdating}
                    onClick={toggleSubscription}
                >
                    {isSubscribed ? "Subscribed" : "Subscribe"}
                </Button>
            </span>
        </Tooltip>
    );
}