document.addEventListener('DOMContentLoaded', () => {
    const ellipsis = document.querySelectorAll('.fa-ellipsis-v');
    window.addEventListener('click', (e) => {
        ellipsis.forEach(value => {
            if (e.target === value) {
                e.target.nextElementSibling.style.display = "block";
            } else {
                value.nextElementSibling.style.display = "none";
            }
        })
    })
})
