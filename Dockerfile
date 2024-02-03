# Stage 1: Build Stage
FROM node:14 as builder

# Create a non-root user for building
RUN groupadd -r docker && useradd -r -g docker rifat

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY . .

# Build the application
RUN npm run build

# Stage 2: Production Stage
FROM node:14-alpine

# Create a non-root user for running the application
RUN addgroup -S docker && adduser -S rifat -G docker

# Set the working directory
WORKDIR /app

# Copy only the necessary files from the builder stage
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# Change ownership to the non-root user
RUN chown -R rifat:docker /app

# Switch to the non-root user
USER rifat

# Expose the port your app runs on
EXPOSE 3000

# Specify the command to run your application
CMD ["node", "server.js"]
