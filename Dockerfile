# Stage 1: Build the Next.js app
FROM node:18-alpine AS nextjs-builder

# Set working directory
WORKDIR /app/frontend

# Copy only package.json and package-lock.json for caching
COPY frontend/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the Next.js app code
COPY frontend/ .

# Build the Next.js app
RUN npm run build

# Stage 2: Set up the FastAPI app
FROM python:3.10-slim AS fastapi

# Set working directory
WORKDIR /app/backend

# Copy FastAPI dependencies
COPY backend/requirements.txt .

# Install FastAPI dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the FastAPI app code
COPY backend/ .

# Expose the FastAPI port (usually 8000)
EXPOSE 8000

# Command to run FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# Stage 3: Serve the Next.js app with a web server (like Nginx)
FROM nginx:alpine AS nginx

# Copy Next.js build output to Nginx
COPY --from=nextjs-builder /app/frontend/.next /usr/share/nginx/html

# Copy Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose Nginx port (usually 80)
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
