# SleepyDriver (v1.11.7) 😴💤🚗
## A CNN-based Mobile Application for Real-Time Driver Fatigue Detection across Varying Light Conditions 

A driver drowsiness-detection mobile application that serves as a support tool for drivers on long journeys during early mornings and late nights. Built with Flutter and Firebase, and following a combination of MVVM and layered architectures, this application is designed to detect drowsiness in drivers under varying lighting conditions to improve road safety. 

## About
Around the world, fatigue accounts for 21% of car accidents. They are destructive and endanger not only their own lives but also the lives of others on the road, especially when carrying passengers between destinations. This is exacerbated at nighttime and on rural roadways, which are often poorly lit. In Sri Lanka itself, bus & tuk-tuk drivers and logistics companies’ truck drivers face a serious risk. Other similar applications require a well-lit environment and rely narrowly on eye movement to monitor fatigue. User-appearance-wise, it is catered to the global population; people with different appearances/skin tones are underrepresented. 

Therefore, SleepyDriver detects fatigue across **varying light environments**.** From real-time monitoring to an alert system and recommended solutions, this application solves a deadly issue and improves safety by refining a pre-trained AI model. 

The Unified Process was followed to build this project; it saves cost and time, and prioritizes a flexible, incremental, and iterative approach.

* **Problem:** Driver drowsiness results in a staggering number of accidents, especially in dark environments and rural areas. 
* **Objectives**: Detect driver fatigue in low-lit/dim light environments (eye blinking, yawning, head drooping), in people of different appearances, and train a CNN-based drowsiness detection model
* **Target audience:** Optimized for both urban & rural users and prioritizes local relevance, minimal user interaction, and driver safety.
* **Technology**: Flutter, Firebase & Firestore, BLOC state management, GitHub, MVVM architecture (Model-View-ViewModel)

## Key Features
### Secure Authentication 
* Secure login using phone number and OTP verification
* Real-time OTP delivery for secure user authentication
* Firebase Authentication for secure session management
* Secure logout and account deletion

### User Profile Management
* Create and manage profile details
* Update personal profile details
* Persistent user data stored securely in Firebase Firestore
* Safe session handling and destruction with the logout feature

### Drowsiness Detection
* MobileNetV3-based CNN classification with facial landmark analysis to detect driver fatigue in real time.
* Eye Aspect Ratio, Mouth Aspect Ratio, and head-pitch-based nodding are calibrated with temporal thresholds to distinguish sustained fatigue from isolated facial movements.
* An adaptive calibration process personalizes EAR and MAR thresholds for each driver

### Alarm System
* Drowsiness is classified based on severity levels: Active, Mild, Moderate, and Severe
* Severity-based audio and vibration alarms provide immediate feedback, along with specific alert screens
* Drowsiness alerts are also recorded against the active trip for later review.

### Recommendations & Nearby Rest Stops
* Identifies nearby suitable rest stops like restaurants, cafes, fuel stations, and designated parking spaces when driver fatigue is detected, through the use of Overpass API
* Provides recommended stopping locations based on the driver's current location
* Displays useful rest-stop information such as distance, rating, opening status, address, and opening hours
* Allows navigation to recommended nearby rest-stops through redirection to GoogleMaps/AppleMaps, with fallback to OpenStreetMap
* Supports safe decision-making by guiding drivers toward appropriate places to take a break

### Trip History 
* View previous trip history
* Displays trip date, duration, and start/end times
* Records drowsiness alerts associated with each trip, and the amount and durations of breaks
* Provides useful insights into driver behaviour and fatigue patterns

### Break Management
* Records driver breaks during trips
* Stores break start and end times
* Calculates break duration

## CNN-Model

### Datasets
Data from the Driver Drowsiness Dataset (ismailnasri20),	NTHU Dataset (samymesbah), and MRL Dataset (akashshingha850) were cleaned, preprocessed and resized to a 224 x 224 size. The data is highly diverse, comprising individuals of different appearances, particularly South Asians, wearing glasses, and various eye states in different lighting conditions, making it highly suitable since SleepyDriver's target audience is Sri Lankans, and the objective is detecting drowsiness across varying light conditions.

### SleepyDriver Model
Several MobileNetV3 models were trained and evaluated using transfer learning and fine-tuning with ImageNet weights. First, the backbone layers were frozen, then trained on preprocessed, augmented data, before the backbone layers were unfrozen. The model was compiled and trained again, then validated and evaluated on unseen test data. This makes it highly efficient and robust to our scenario. The models achieved high accuracy and performed well, particularly with Drowsy Recall. 

### Results
The selected MobileNetV3 model produced 96.99% Accuracy, 98.19% Precision, 97.15% Recall, and 97.66% F1-Score. The model correctly classified 10,016 of 10,310 drowsy samples, with 294 false negatives and 185 false positives. The high Drowsy recall was particularly important for the safety-oriented application, as it reduces the likelihood of genuine drowsiness being missed, and the low number of false classifications also suggests false alarms are less likely. This model was converted into TFLite format for lightweight usage on the mobile device, then integated into the Flutter application.

## Software Design Patterns
* **Facade Pattern:** Applied to the alarm system; AlarmFacade provides a simple interface for controlling multiple underlying services such as audio and vibration. This reduces coupling and simplifies interaction with the alarm subsystem.
* **BLoC Pattern:** Applied to managing application and UI state through events and states. This separates presentation from business logic and is suitable for asynchronous processes such as camera processing, drowsiness inference, alarms, trip management, and cloud communication. This improves maintainability and provides predictable state transitions.
* **Observer Pattern:** Applied through the BLoC state-management mechanism, where UI components listen for state changes and react when new states are emitted. This allows changes such as drowsiness detection, alarm activation, trip updates, and break status to be moved to the relevant UI components without the BLoC directly controlling the UI, reducing coupling between components.
* **Dependency Injection:** Applied by supplying repositories, services, and other dependencies through constructors rather than creating them inside the classes that use them. This reduces tight coupling and allows different implementations, such as test or mock services, to be substituted easily.
 
## Screenshots
<img width="350" height="800" alt="splash" src="https://github.com/user-attachments/assets/ef8fac5b-108b-4d0c-9ac1-0d726a68c216" />
<img width="350" height="800" alt="login" src="https://github.com/user-attachments/assets/1d996c39-8d42-4622-9e42-b23ac80cc68c" />
<img width="350" height="800" alt="register" src="https://github.com/user-attachments/assets/77f669a7-5c66-487f-9a2c-36607f1b9a62" />
<img width="350" height="800" alt="profile" src="https://github.com/user-attachments/assets/ff836772-910c-4075-843e-f5531291ffd3" />
<img width="350" height="800" alt="dashboard" src="https://github.com/user-attachments/assets/c885f682-f580-45fd-8854-6ace6aa8cbad" />
<img width="350" height="800" alt="safety" src="https://github.com/user-attachments/assets/7bd7a582-a222-4366-a163-12fcac515438" />
<img width="350" height="800" alt="des" src="https://github.com/user-attachments/assets/863ecdda-a9bb-4588-8a3d-fa5754606daa" />
<img width="350" height="800" alt="mild" src="https://github.com/user-attachments/assets/adfe8311-5e75-4cb5-bca9-ed5f7d26552b" />
<img width="350" height="800" alt="mod" src="https://github.com/user-attachments/assets/47e5e88b-a880-47ca-96ba-74e28e5660af" />
<img width="350" height="800" alt="severe" src="https://github.com/user-attachments/assets/d177647a-940e-40b0-a4be-7e5e5deb102c" />
<img width="350" height="800" alt="triphistory" src="https://github.com/user-attachments/assets/3ac50a52-4959-447a-bb80-950b9af34b2e" />
<img width="350" height="800" alt="pg1" src="https://github.com/user-attachments/assets/cbf79f44-a1d7-462e-a1a1-08a01759c89d" />
<img width="350" height="800" alt="pg5" src="https://github.com/user-attachments/assets/a1719466-f21b-43ac-b992-c82b1f867b43" />

## Architecture & Technology Stack
The mobile application uses layered architecture with MVVM to separate responsibilities among the presentation, business logic, data, and Firebase service layers.
* **Presentation Layer**: Interfaces built with Flutter (stateful and stateless widgets) for user interactions.
* **BLoC / View Model**: Manages application state and UI updates, acting as the bridge between data and UI, like updating UI based on drowsiness predictions
* **Repository Layer**: Acts as an abstraction between the application logic and data sources.
* **Service Layer**: Handles authentication, Firestore operations, location services, drowsiness alerts, trip management, and recommendations.
* **Model Layer**: Defines structured data models

Following the layered-architecture approach supports the system, making it more scalable and easier to read and maintain.

### Frontend & Application
* Flutter: Cross-platform mobile application development
* Dart: Primary programming language
* State Management - Business Logic of Component (BLoC, Events and States)
  
### Machine Learning & Computer Vision
* Python: Primary programming language for data preprocessing, model training, and evaluation
* TensorFlow / TensorFlow Lite: Real-time, lightweight drowsiness detection that allows the model to run inference on an edge device

### Backend & Cloud Services
* Firebase Authentication: Phone number and OTP authentication
* Cloud Firestore: Stores users, trips, breaks, drowsiness alerts, and related data

### Location & Navigation
* Geolocation: Obtains the driver's current location (latitude and longitude)
* Overpass API: Provides information about suitable stopping locations
* Map & Routing Services like Google Maps and Apple Maps: Supports route calculation and navigation toward recommended rest stops

### Version Control
* CI/CD pipeline: GitHub

This stack enables the application to combine real-time drowsiness detection, location-aware safety recommendations, cloud-based data management, and trip/fatigue monitoring within a single mobile platform.

## Getting Started
### Prerequisites
Before running SleepyDriver, ensure you have the following installed:
- Flutter SDK
- Android Studio
- Android device or emulator
- A configured Firebase project

### How to install
#### Option 1: Download the ZIP file

1. Click **Code** at the top of the repository
2. Click **Download ZIP**
3. Once the repository is downloaded, extract the ZIP file to access the repository's files

#### Option 2: Clone the repository
1. Click **Code** at the top of the repository
2. Copy the URL from the HTTPS tab
3. Open your terminal and change the working directory to your preferred location
4. Run the clone command below:
```bash
git clone https://github.com/salma-shah/cis6035-cnn-driver-drowsiness-detection-mobile-app
```
5. Install Flutter dependencies
```bash
flutter pub get
```

#### After download
1. Configure Firebase for the project and ensure the required services are enabled:

* Firebase Authentication
* Cloud Firestore
* Cloud Functions

2. Connect an Android device or start an emulator, then run:
```bash
flutter run
```
For a physical device, ensure that camera and location permissions are enabled.
Note: SleepyDriver is currently developed and tested primarily on Android. iOS support is planned as a future enhancement.

## CI/CD Pipeline
Branch strategy:
* ```development``` : Development environment for new features
* ```qa```: Isolated, stable environment to test features and verify code stability safely for QA
* ```regression```: Address and prevent software regression, to make isolated changes by refactoring skeletal code to ensure bugs do not 'sneak in' past initial tests again 
* ```master```: Production environment for deployment and live-monitoring

Version-control techniques:
* Merging: Once a feature was fully complete and working, its branch was merged into ```development``` branch before deletion
* Commits & Pushes: Following Unified Process, small incremental commits were pushed to the ```development``` branch, serving a single purpose and making it easier to track
* Pull Requests (PR): When pushing commits to ```master```, a pull request was created to review before selectively integrating changes
* Deployment: After thorough testing, code is pushed from ```qa``` branch to ```master``` branch

Commit-History: Commits to ```development``` branch history can be viewed [here](https://github.com/salma-shah/cis6003-hotel-management-system/commits/development/)

```master``` branch holds only the 'shippable' code; therefore, only pull requests were made to it, following real-world best practices. 

Following and integrating into the CI/CD pipeline ensures that only safely tested and reviewed code is delivered to the production environment, with minimal disruptions that could cause damage. This is crucial considering the safety-critical nature of SleepyDriver. 

## Version
* Version: SleepyDriver v1.11.7
* Last updated: 31st August 2025

## Lessons Learned
* One of the main lessons from developing and training a model was that accuracy alone is not a sufficient predictor of drowsiness alone. Metrics like Precision, F1-Score, and Recall are equally important, especially because missing a drowsy driver is more dangerous than a false alarm. This demonstrated how crucial it is for the model design itself to meet the application’s requirements. 
* Combining layered architecture with the MVVM approach was practical, allowing for easy bug tracing and delegating responsibilities across layers. It was especially beneficial when UI updates needed to be frequent, like updating the screen for every drowsy prediction received.
* The project itself was challenging and intuitive, going beyond a basic prediction model taught during the module. It gave me lots of knowledge regarding how to clean and process image data, which is quite different from tabular data, and to fine-tune a pretrained model. While challenges arose with integrating the model into the Flutter application and ensuring the application does not crash, solving them allowed me to learn beyond the scope of this project. I hope to utilize this knowledge and build more computer-vision-based applications in the future.
* The most important lesson of them all would have to be the realization is that with the knowledge I gained from my BSc in Software Engineering, I can apply it to attempt to solve issues people around me actually face, and that other developers should too. As the final project of my BSc in Software Engineering, SleepyDriver allowed me to apply my skills and learning to produce a fully functional mobile application that can actively work towards solving a prevalent issue, if utilized correctly, rather than just another academic project.

## Contribution
If you would like to contribute to this repository:
1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes, then commit them (`git commit -m 'Add your feature'`)
4. Push to the branch (`git push origin feature/your-feature-name`)
5. Open a pull request

## Contact
* Email: salma.shah.0516@gmail.com
* LinkedIn: www.linkedin.com/in/salma-shah-0b499724a

## Acknowledgement
* I extend my gratitude towards my final project supervisor, Miss Nimesha Amarasingha, for her support and guidance throughout the project development.

Any contributions or suggestions are welcome! I'd appreciate a star on the project :) Thank you!

