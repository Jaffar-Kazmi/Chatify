import axios from 'axios';
import dotenv from 'dotenv';

dotenv.config();

const HF_API_TOKEN = process.env.HF_API_TOKEN;
if (!HF_API_TOKEN) {
  throw new Error('HF_API_TOKEN environment variable is not set');
}

const API_URL = 'https://router.huggingface.co/v1/chat/completions';

// List of random themes to force the AI to be different every time
const THEMES = [
  "travel", "food", "childhood memories", "future technology", 
  "superpowers", "hobbies", "movies", "music", "animals", 
  "embarrassing moments", "dream jobs", "outer space"
];

export async function generateDailyQuestion() {
  try {
    // 1. Pick a random theme
    const randomTheme = THEMES[Math.floor(Math.random() * THEMES.length)];

    const response = await axios.post(
      API_URL,
      {
        model: "Qwen/Qwen2.5-7B-Instruct",
        messages: [
          { 
            role: "user", 
            // 2. Inject the theme into the prompt so the input is always unique
            content: `Generate one fun, unique daily conversation question about ${randomTheme}. Output ONLY the question.` 
          }
        ],
        max_tokens: 100,
        stream: false,
        temperature: 1.0, // 3. Maximum randomness
        frequency_penalty: 0.5 // 4. Discourages repeating common phrases
      },
      {
        headers: {
          'Authorization': `Bearer ${HF_API_TOKEN}`,
          'Content-Type': 'application/json',
        }
      }
    );

    if (response.data && response.data.choices && response.data.choices.length > 0) {
      const question = response.data.choices[0].message.content.trim();
      console.log(`[AI Question - ${randomTheme}]: ${question}`);
      return question;
    }
    
    return "What is your favorite hobby?";

  } catch (error: any) {
    if (error.response) {
      if (error.response.status !== 503) {
         console.error('Data:', JSON.stringify(error.response.data, null, 2));
      } else {
         console.log("Model is loading... (503)");
      }
    } else {
      console.error('Error:', error.message);
    }
    return "If you could travel anywhere, where would you go?";
  }
}