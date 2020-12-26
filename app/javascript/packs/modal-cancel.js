document.addEventListener('DOMContentLoaded', () => {
    const cancel = document.querySelectorAll(".modal__cancel");

    cancel.forEach( c => {
        c.addEventListener("click", (b) => {

            let overlayType = document.getElementById("overlay-type").value;
            let overlay = document.getElementById(`overlay-${overlayType}`);
            overlay.style.display = "none";

        })
    })
})
