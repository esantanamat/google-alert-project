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
    };

    try {
        const response = await fetch('https://3yq9qqzl9l.execute-api.us-east-1.amazonaws.com/', {
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