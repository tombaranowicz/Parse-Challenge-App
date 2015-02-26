# Parse-Challenge-App
iPhone app built using Parse. Enables creating new challenges, nominating friends, posting challenge attempts (image/video), commenting, giving likes, sharing challenges and attempts to challenges.

App preview:
- iTunes: https://itunes.apple.com/us/app/lets-challenge-me/id944004497
![Challenge](http://a1.mzstatic.com/us/r30/Purple3/v4/d4/ee/da/d4eedae5-c3ba-9711-f77b-70d4ab155c90/screen322x572.jpeg)
![Challenge](http://a2.mzstatic.com/us/r30/Purple1/v4/2f/d3/7a/2fd37a68-f5c0-1360-5cc6-2db21436f029/screen322x572.jpeg)
![Challenge](http://a5.mzstatic.com/us/r30/Purple3/v4/2f/12/fb/2f12fb0e-59fe-f876-172f-fdb48774bbc4/screen322x572.jpeg)

Features:
- creating new challenge
- adding own challenge attempt (with video/image)
- commenting
- giving likes
- reporting inappropriate content
- searching users/challenges
- sharing
- nominating other users
- user profile customization

Requirements:
- Xcode 6
- iOS 8.0

Parse Classes:

User
- username String
- password String
- authData authData
- emailVerified Boolean
- challenges Numb
- eremail String
- facebookId String
- profile Object
- profileImage File
- profileImageThumb File
- solutions Number

Challenge
- author Pointer<_User>
- name String
- description String
- comments Number
- image File
- likes Number
- solutions Number
- comment String

ChallengeSolution
- challenge Pointer<Challenge>
- comment String
- comments Number
- image File
- movie File
- likes Number
- user Pointer<_User>

Comment
- author Pointer<_User>
- challenge Pointer<Challenge>
- challengeSolution Pointer<ChallengeSolution>
- comment String

FlagRequest
- author Pointer<_User>
- challenge Pointer<Challenge>
- challengeSolution Pointer<ChallengeSolution>
- reason String
- user Pointer<_User>

Like
- author Pointer<_User>
- challenge Pointer<Challenge>
- challengeSolution Pointer<ChallengeSolution>

Nomination
- challenge Pointer<Challenge>
- from Pointer<_User>
- to Pointer<_User>
- to FacebookId String
