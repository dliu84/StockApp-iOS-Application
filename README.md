# StockApp - iOS Application

## Overview
**StockApp** is an intuitive and powerful application designed for tracking, monitoring, and analyzing stock market trends. It enables users to search for companies, monitor their performance, classify stocks into lists, rank them based on potential, and mark them as favorites-all while ensuring data persistence for a seamless user experience.

## Key Features
- **Stock Selection and Monitoring**: Users can select stocks to monitor and classify them into a watch list or active list.
- **Search and Discovery**: Intuitive interface for efficient and fast searching with a dedicated `SearchViewController` for finding new stocks.
- **Stock Ranking and Visual Cues**: Users can rank stocks as "Cold," "Hot," or "Very Hot" with Visual indicators such as icons and background colors for each rank.
- **Favorites Management**: Users can mark stocks as favorites by tapping the star icon next to each stock in the "Active" and "Watching" sections
- **Real-Time Data Refresh**: Ensures users always have the latest market information with a pull-to-refresh feature for updating stock data in real-time.
- **Data Persistence**: CoreData provides consistent functionality across sessions, ensuring user preferences, selected stocks, rankings, and list placements are saved.
- **Flexible List Management**: User-friendly design for effortless list management with seamless transitions of stocks between the watching list and active list.
  
## Technology Stack
- **Frontend**: Swift and UIKit for building the iOS application.
- **Backend/API integration**: Integrated with the RapidAPI: MS Finance API for fetching stock data. Adheres to API best practices and specifications
- **Database**: CoreData for local data persistence.

## Project Structure
- **Stock Selection**: Choose stocks for monitoring and classification into different lists.
- **Search**: Locate companies through the `SearchViewController` with an efficient interface.
- **Rank and Visualize**: Categorize stocks with "Cold," "Hot," and "Very Hot" rankings using meaningful visual cues.
- **Favorites Management**: Mark and unmark stocks as favorites using a star icon.
- **Real-Time Updates**: Update stock prices with a pull-to-refresh mechanism.
- **Data Persistence**: Ensure user data is securely saved for consistent experiences.
  

## Installation and Setup
#### Clone the Repository: Clone this repository to your local machine:
  `git clone https://github.com/username/StockApp.git`

## Build and Run
#### Open the project in Xcode and select your simulator or device. Build and run the application:
  `cmd + R`

## Usage Instructions
- **Search for Stocks**: Use the search feature to find companies quickly.
- **Monitor Stocks**: Add stocks to your watch or active lists and view real-time updates.
- **Rank Stocks**: Assign ranks to stocks and visualize their potential with icons or colors.
- **Manage Favorites**: Mark stocks as favorites with the star icon for quick access.
- **Refresh Data**: Pull to refresh stock data and ensure accuracy.

## Contributors

- **Professor Satiar Rad** (Instructor, Seneca Polytechnic, MAP523, 2024 Fall)  
- **Di Liu** - [dliu84](https://github.com/dliu84)  

