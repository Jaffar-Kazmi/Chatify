export const AI_BOT_ID = "00000000-0000-0000-0000-000000000000";

export const getBaseUrl = (): string => {
    const baseUrl = process.env.BASE_URL || 'http://localhost';
    const port = process.env.PORT || '3000';
    
    if (baseUrl.includes(":" + port)) {
        return baseUrl;

    }

    return `${baseUrl}:${port}`;
}

export const BASE_URL = getBaseUrl();