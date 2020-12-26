document.addEventListener('DOMContentLoaded', () => {
    const deleteConfirmation = document.querySelectorAll('.channel-message-data__delete-message-confirm');
    deleteConfirmation.forEach( d => {
        d.addEventListener('click', (e) => {
            document.getElementById("overlay-type").value = "delete-message";
            let overlayType = document.getElementById("overlay-type").value;
            let overlay = document.getElementById(`overlay-${overlayType}`);

            overlay.style.display = "block";

            const messageId = e.target.parentNode.value;
            document.getElementById("delete-message-num").value = messageId;
        });
    });

    const deleteExec = document.querySelectorAll(".modal__delete-message");
    deleteExec.forEach( d => {
        d.addEventListener("click", (e) => {
            const message = document.getElementById("delete-message-num").value;

            document.getElementById(message).click();

            let overlayType = document.getElementById("overlay-type").value;
            let overlay = document.getElementById(`overlay-${overlayType}`);
            overlay.style.display = "none";
        })
    })
})
