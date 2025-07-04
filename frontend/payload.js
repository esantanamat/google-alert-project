document.getElementById('notificationForm').addEventListener('submit', async (event) => {
    event.preventDefault();

    const formData = {
        user_id: Number(document.getElementById('user_id').value),
        destination_name: document.getElementById('destination_name').value,
        arrival_time: document.getElementById('arrival_time').value,
        arrival_datetime: document.getElementById('arrival_datetime').value,
        is_one_time: document.querySelector('input[name="is_one_time"]:checked')?.value,
        origin_address: document.getElementById('origin_address').value,
        destination_address: document.getElementById('destination_address').value,
        phone_number: document.getElementById('phone_number').value,
        email_address: document.getElementById('email_address').value
    };

    try {
        const config = await fetch('config.json').then(res => res.json());

        const API_GATEWAY_URL = config.api_url;
        console.log(API_GATEWAY_URL)
        const response = await fetch(`${API_GATEWAY_URL}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(formData)
        });

        if (response.ok) {
            alert("Notification added successfully!");
        } else {
            alert("Failed to add notification.");
        }
    } catch (err) {
        console.error(err);
        alert("Error submitting form.");
    }
});

function toggleTime(decision) {
    const constantreminder = document.getElementById('arrival_time')
    const labelconstantreminder = document.getElementById('label_arrival_time')
    const singlereminder = document.getElementById('arrival_datetime')
    const labelsinglereminder = document.getElementById('label_arrival_datetime')
    if (decision == true) {
        constantreminder.style.display = 'none'
        labelconstantreminder.style.display = 'none'
        singlereminder.style.display = 'block'
        labelsinglereminder.style.display = 'block'


    }
    else {
        constantreminder.style.display = 'block'
        labelconstantreminder.style.display = 'block'
        singlereminder.style.display = 'none'
        labelsinglereminder.style.display = 'none'
    }
}