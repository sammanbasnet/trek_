const mongoose = require('mongoose');
const Package = require('./models/Package');

// Connect to MongoDB
mongoose.connect('mongodb://127.0.0.1:27017/trek_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

const testPackages = [
  {
    title: 'Everest Base Camp Trek',
    description: 'Experience the ultimate adventure with our Everest Base Camp trek. This iconic journey takes you through the heart of the Himalayas, offering breathtaking views of the world\'s highest peak.',
    location: 'Everest Region, Nepal',
    price: 1200,
    duration: '14 days',
    category: 'Mountain',
    availableDates: [new Date('2024-03-15'), new Date('2024-04-10'), new Date('2024-05-05')],
    itinerary: ['Day 1: Arrival in Kathmandu', 'Day 2: Fly to Lukla', 'Day 3: Trek to Namche Bazaar', 'Day 4: Acclimatization day', 'Day 5: Trek to Tengboche'],
    image: 'everest.jpg'
  },
  {
    title: 'Annapurna Circuit Trek',
    description: 'Discover the diverse landscapes of the Annapurna region with this comprehensive trek that takes you through lush forests, high mountain passes, and traditional villages.',
    location: 'Annapurna Region, Nepal',
    price: 950,
    duration: '12 days',
    category: 'Mountain',
    availableDates: [new Date('2024-03-20'), new Date('2024-04-15'), new Date('2024-05-10')],
    itinerary: ['Day 1: Arrival in Kathmandu', 'Day 2: Drive to Besisahar', 'Day 3: Trek to Chame', 'Day 4: Trek to Manang', 'Day 5: Acclimatization day'],
    image: 'annapurna.jpg'
  },
  {
    title: 'Rara Lake Trek',
    description: 'Explore the pristine beauty of Rara Lake, the largest lake in Nepal. This remote trek offers stunning mountain views and a peaceful escape into nature.',
    location: 'Rara Lake, Nepal',
    price: 800,
    duration: '10 days',
    category: 'Lakes',
    availableDates: [new Date('2024-03-25'), new Date('2024-04-20'), new Date('2024-05-15')],
    itinerary: ['Day 1: Arrival in Kathmandu', 'Day 2: Fly to Nepalgunj', 'Day 3: Drive to Talcha', 'Day 4: Trek to Rara Lake', 'Day 5: Explore Rara Lake'],
    image: 'rara.jpg'
  },
  {
    title: 'Tilicho Lake Trek',
    description: 'Journey to the highest lake in the world at 4,919 meters. This challenging trek rewards you with spectacular views of the Annapurna range.',
    location: 'Annapurna Region, Nepal',
    price: 1100,
    duration: '15 days',
    category: 'Lakes',
    availableDates: [new Date('2024-03-30'), new Date('2024-04-25'), new Date('2024-05-20')],
    itinerary: ['Day 1: Arrival in Kathmandu', 'Day 2: Drive to Besisahar', 'Day 3: Trek to Chame', 'Day 4: Trek to Manang', 'Day 5: Acclimatization day'],
    image: 'tilicho.jpg'
  }
];

async function addTestPackages() {
  try {
    console.log('Connecting to database...');
    await mongoose.connection.asPromise();
    console.log('Connected to MongoDB');

    // Clear existing packages
    await Package.deleteMany({});
    console.log('Cleared existing packages');

    // Add test packages
    const savedPackages = await Package.insertMany(testPackages);
    console.log(`Added ${savedPackages.length} test packages:`);
    
    savedPackages.forEach(package => {
      console.log(`- ${package.title} ($${package.price})`);
    });

    console.log('Test packages added successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error adding test packages:', error);
    process.exit(1);
  }
}

addTestPackages(); 