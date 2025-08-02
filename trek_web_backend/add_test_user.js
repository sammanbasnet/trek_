const mongoose = require('mongoose');
const Customer = require('./models/Customer');

// Connect to MongoDB
mongoose.connect('mongodb://127.0.0.1:27017/trek_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const testUser = {
  fname: 'Test',
  lname: 'User',
  email: 'test@example.com',
  password: 'password123',
  phone: '1234567890',
  role: 'customer'
};

async function addTestUser() {
  try {
    console.log('Connecting to database...');
    await mongoose.connection.asPromise();
    console.log('Connected to MongoDB');

    // Check if test user already exists
    const existingUser = await Customer.findOne({ email: testUser.email });
    if (existingUser) {
      console.log('Test user already exists. Updating password...');
      existingUser.password = testUser.password;
      await existingUser.save();
      console.log('Test user password updated successfully!');
    } else {
      // Create new test user
      const user = await Customer.create(testUser);
      console.log('Test user created successfully!');
      console.log(`Email: ${user.email}`);
      console.log(`Password: ${testUser.password}`);
    }

    console.log('\nTest User Credentials:');
    console.log(`Email: ${testUser.email}`);
    console.log(`Password: ${testUser.password}`);
    console.log('\nYou can now use these credentials to log in to your Flutter app!');
    
    process.exit(0);
  } catch (error) {
    console.error('Error adding test user:', error);
    process.exit(1);
  }
}

addTestUser(); 