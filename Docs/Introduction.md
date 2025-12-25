# Police State Exam App

## Introduction

In this document we will explain in the design, requirements and
goals for the development of an app that uses a gamified learning style
as duolingo for the police statal exam in spain. We aim to create in
less than two months the first iteration of the app which consists in
three keypoints:

- **Database**: Creating a dataset with the exam questions and a
  database accessible by the backend to server questions to the
  frontend. The database will also have to store the information for the
  users and everything needed for the app.

- **App**: The app is divided in two keypoints:

  - **Frontend**: The appearance of the app, a modern and intuitive UI
    that makes learning fun and easy, an app with a strong social
    component with laderboards, leagues and friendly matches, a
    personally focused app with tailored sets of lessons based on the
    users weak and strong points, an app that encourages personal
    development with extra lesson challenges as, how many questions
    without failing in a row you can do, or lightning rounds.

  - **Backend**: A robust server that will serve the questions to the
    frontend, the information for the social activity and will carry all
    the logic and data management needed.

- **Learning path**: The order, quantity and frequency of questions
  delivered to the user, the learning experience, the types of lessons,
  etc. Will be designed by an expert in the field so the learning curve
  is smooth and ensures enjoyable and useful learning. The expert will
  decide the content of the lessons, their order and some parameters of
  the challenges.

This three keypoints will interact with each other's, the interaction
between the app and the database is obvious but a deeper introduction
for the other interactions must be said:

- **Database -- Learning path interaction:** The learning expert that
  will design the lessons is not computer fluent, and the questions and
  syllabus of this type of exams is quite volatile, so the learning
  expert will need to edit, add and delete questions from the database
  at any moment. As he will not learn how to use sql, a learning expert
  dashboard must be created apart of the app. A website with
  authentication that will be served by the server where the learning
  expert can see, edit add and delete questions from the database
  easily.

- **App -- Learning path interaction:** The app will only be a lesson
  delivery interface, the structure of a lesson will always be the same,
  a set of ordered sessions and a session is a set of random questions
  selected with certain parameters. The lessons are not going to be
  hardcoded, as we said earlier the syllabus is volatile and the
  learning expert needs to be able to modify the learning path easily.
  For this reason the lessons should be created, edited and deleted from
  the dashboard also, saved in the database and then the app will server
  them in the stipulated order. So the app will only be an skeleton
  ready to server lessons and the early mentioned challenges, which will
  have an algorithmic behavior but the parameters of that algorithms
  also have to be editable by the learning expert.
