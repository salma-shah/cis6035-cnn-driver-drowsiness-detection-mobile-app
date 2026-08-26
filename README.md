# SleepyDriver; CNN-based Mobile Application for Real-Time Driver Fatigue Detection across Varying Light Conditions 😴💤🚗

A driver drowsiness detection mobile application that acts as a support tool for drivers who drive long journeys during early mornings and late nights. Built with Flutter and Firebase, following a combination of MVVM and layered architecture, this application is designed to detect drowsiness in drivers across varying light conditions to improve road safety. 

## Demonstration: 

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
* Secure login authentication with phone number and OTP verification
* OTPs sent to phone number in real-time, ensuring strong security

### User Profile Management
* Update and manage profile details
* Safe session handling and destruction with the logout feature

### Drowsiness Detection


### Recommendations & Nearby Rest Stops

### Trip History 
* User trip history can be viewed
* Information like trip date, duration and start-end times are displayed
* Each trip contains details regarding drowsiness alerts and number of breaks to provide valuable insights regarding driver behaviour and fatigue

## CNN-Model

### Datasets
Data from the Driver Drowsiness Dataset (ismailnasri20),	NTHU Dataset (samymesbah), and MRL Dataset (akashshingha850) were cleaned, preprocessed and resized to 224 x 224 size. The data is highly diverse, comprising individuals of different appearances, particularly South Asians, wearing glasses, and various eye states in different lightings, making it highly suitable since SleepyDriver's target audience is Sri Lankans, and objective is detecting drowsiness across varying light conditions.

### SleepyDriver Model
Several MobileNetV3 models were trained and evaluated by the process of transfer learning and fine-tuning utilizing ImageNet weights. First, the backbone layers were frozen, then trained on preprocessed, augmented data, before the backbone layers were unfrozen. The model was compiled and trained again, then validated and evaluated on unseen test data. This makes it highly efficient and robust to our scenario. The models achieved high accuracy and performed well, particularly with Drowsy Recall. 

### Results

## Software Design Patterns

## Screenshots

## Architecture & Technology Stack

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

## Lessons Learned

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

