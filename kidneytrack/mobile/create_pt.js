const url = 'https://xrdaimedsdxbfjoyvhpx.supabase.co/auth/v1/signup';
const key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhyZGFpbWVkc2R4YmZqb3l2aHB4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQwNjgyOTYsImV4cCI6MjA4OTY0NDI5Nn0.whuh7ZKrUUiWzReUy7bPHm7kbANA7pigkxEfbkOMN80';

async function createPatient() {
  try {
    const res = await fetch(url, {
      method: 'POST',
      headers: {
        'apikey': key,
        'Authorization': `Bearer ${key}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        email: 'test_patient@glomea.com',
        password: 'Password123!',
        data: {
          firstName: 'مريض',
          lastName: 'تجريبي'
        }
      })
    });
    const data = await res.json();
    if (res.ok) {
      console.log('SUCCESS:', data.user.email);
    } else {
      console.error('ERROR:', data);
    }
  } catch(e) {
    console.error(e);
  }
}
createPatient();
