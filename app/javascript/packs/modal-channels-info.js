document.addEventListener('DOMContentLoaded', () => {
    const channelsInfo = document.querySelectorAll(".channels__about-number-of-people");
    channelsInfo.forEach( c => {
        c.addEventListener("click", (e) => {
            document.getElementById("overlay-type").value = "channels-info";
            let overlayType = document.getElementById("overlay-type").value;
            let overlay = document.getElementById(`overlay-${overlayType}`);

            overlay.style.display = "block";
        })
    })
})
