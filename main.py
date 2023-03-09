from flask import Flask, jsonify, request, make_response
import jwt

import tensorflow as tf
import numpy as np
from keras.models import Model, load_model
import cv2
from PIL import Image
from random import randint

from functools import wraps
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy.orm import relationship
from datetime import datetime, timedelta
import werkzeug
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import UserMixin, login_user, LoginManager, login_required, current_user, logout_user

app = Flask(__name__)

# Connect to Database
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///madicals.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['SECRET_KEY'] = 'something_secret_i_guess'
db = SQLAlchemy(app)


new_model = load_model('./effnet.h5')

# token required
def token_required(func):
    @wraps(func)
    def decorated(*args, **kwargs):
        token = request.headers.get('token')
        if not token:
            return jsonify({'Alert!': 'Token is missing!'}), 400
        try:
            payload = jwt.decode(token, app.config['SECRET_KEY'], ["HS256"])
            if not User.query.filter_by(email=payload['email']).first():
                current_user = Hospital.query.filter_by(email=payload['email']).first()
            else:
                current_user = User.query.filter_by(email=payload['email']).first()

        except Exception as e:
            print(e)
            return jsonify({'Alert!': 'Invalid token!'}), 401
        return func(current_user, *args, **kwargs)

    return decorated


class Hospital(UserMixin, db.Model):
    __tablename__ = 'hospital'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(250), nullable=False)
    email = db.Column(db.String(100), nullable=False, unique=True)
    password = db.Column(db.String(50))
    location = db.Column(db.String(250), nullable=False)
    about = db.Column(db.String(250), nullable=False)
    patients = relationship("Appointment", back_populates="hospital")

    def __init__(self, name, email, password, location, about):
        self.name = name
        self.email = email
        self.password = password
        self.location = location
        self.about = about

    def to_dict(self):
        return {column.name: getattr(self, column.name) for column in self.__table__.columns}


db.create_all()


class User(UserMixin, db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(250), nullable=False)
    email = db.Column(db.String(100), nullable=False, unique=True)
    password = db.Column(db.String(50))
    age = db.Column(db.String, nullable=False)
    appointment = relationship("Appointment", back_populates="user")

    def __init__(self, name, email, password, age):
        self.name = name
        self.email = email
        self.password = password
        self.age = age

    def to_dict(self):
        return {column.name: getattr(self, column.name) for column in self.__table__.columns}


db.create_all()


class Appointment(db.Model):
    __tablename__ = 'appointments'
    id = db.Column(db.Integer, primary_key=True)
    date = db.Column(db.String, nullable=False)
    day = db.Column(db.String, nullable=False)
    time = db.Column(db.String, nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    user_name = db.Column(db.String, nullable=True)
    user = relationship("User", back_populates="appointment")
    hospital_id = db.Column(db.Integer, db.ForeignKey('hospital.id'), nullable=False)
    hospital_name = db.Column(db.String, nullable=False)
    hospital = relationship("Hospital", back_populates="patients")
    status = db.Column(db.String, nullable=False)

    def to_dict(self):
        return {column.name: getattr(self, column.name) for column in self.__table__.columns}


db.create_all()


@app.route('/')
def home():
    return 'You Doing Well, This is my brain tumor classification app as part of a medical booking mobile App'


# fetch all users
@app.route('/all_users')
def all_users():
    all_user = db.session.query(User).all()
    if all_user:
        return jsonify(users=[user.to_dict() for user in all_user])
    else:
        return jsonify(error={'Not Found': 'Sorry, no users at the moment'}), 204


# fetch a user
@app.route('/get_the_user', methods=['POST'])
def get_the_user():
    email = request.form.get('email')
    user = User.query.filter_by(email=email).first()
    if user:
        return jsonify(user=user.to_dict())
    else:
        return jsonify(error={'Not Found': 'Sorry, no such user.'}), 204


# the current user
@app.route('/current_user')
@token_required
def get_current_user(current_user):
    print('lets see')
    print(current_user)
    all_the_hospitals = all_hospitals().json
    try:
        all = all_the_hospitals['Hospitals']
        return jsonify({'Logged_in_user': current_user.to_dict(), 'All_Hospitals': all})
    except Exception as e:
        print(e)
        return jsonify(Logged_in_user=current_user.to_dict())


# register new user
@app.route('/add_user', methods=['GET', 'POST'])
def post_new_user():
    email = request.form.get('email')
    result = User.query.filter_by(email=email).first()
    if result:
        print(result)
        return jsonify(error={'error': 'username already created'}), 208
    else:
        new_user = User(
            name=request.form.get('name'),
            email=request.form.get('email'),
            password=generate_password_hash(request.form.get('password'), method='pbkdf2:sha256', salt_length=8),
            age=request.form.get('age'),
        )
    db.session.add(new_user)
    db.session.commit()
    token = jwt.encode({'email': email,
                        'exp': datetime.utcnow() + timedelta(seconds=140), },
                       app.config['SECRET_KEY'])
    return jsonify({'token': token})


# Get all hospitals  
@app.route('/all_hospitals')
def all_hospitals():
    all_hospital = db.session.query(Hospital).all()
    if all_hospital:
        return jsonify(Hospitals=[hospital.to_dict() for hospital in all_hospital])
    else:
        return jsonify(error={'Not Found': 'Sorry, no hospitals at the moment'})


# fetch an hospital
@app.route('/get_the_hospital')
@token_required
def get_the_hospital(current_user):
    id = request.args.get('id')
    hospital = Hospital.query.filter_by(id=id).first()
    if hospital:
        return jsonify(hospital=hospital.to_dict()), 200
    else:
        return jsonify(error={'Not Found': 'Sorry, no hospital.'}), 204


# Register new hospital      
@app.route('/add_hospital', methods=['GET', 'POST'])
def post_new_hospital():
    email = request.form.get('email')
    try: 
        result = Hospital.query.filter_by(email=email).first()
        if result:
            return jsonify(error={'error': 'username already created'}), 208

        else:
            new_hospital = Hospital(
            name=request.form.get('name'),
            email=request.form.get('email'),
            password=generate_password_hash(request.form.get('password'), method='pbkdf2:sha256', salt_length=8),
            location=request.form.get('location'),
            about=request.form.get('about')
            )
        db.session.add(new_hospital)
        db.session.commit()
        token = jwt.encode({'email': email,
                            'exp': datetime.utcnow() + timedelta(seconds=5), },
                           app.config['SECRET_KEY'])
        return jsonify({'token': token})
    except Exception as e:
        return jsonify({'error': e})

# Login user
@app.route('/login_user', methods=['GET', 'POST'])
def user_login():
    # payload = request.get_json()
    email = request.form.get('email')
    print(email)
    password = request.form.get('password')
    user = User.query.filter_by(email=email).first()
    if not user:
        print('wrong mail')
        return jsonify(error={'Not Found': 'Email does not exist'}), 401
    elif not check_password_hash(user.password, password):
        return jsonify(error={'Not Found': 'Incorrect password'}), 402
        #  return make_response('could not verify',  401, {'Authentication': '"login required"'})
    else:
        token = jwt.encode({'email': email,
                            'exp': datetime.utcnow() + timedelta(seconds=200), },
                           app.config['SECRET_KEY'])
        return jsonify({'token': token})


# Login hospital
@app.route('/login_hospital', methods=['GET', 'POST'])
def hospital_login():
    email = request.form.get('email')
    password = request.form.get('password')
    print(email, password)
    hospital = Hospital.query.filter_by(email=email).first()
    print(hospital)
    if not hospital:
        print("Hospital not found")
        return jsonify(error={'Not Found': 'Email does not exist'}), 403
    if not check_password_hash(hospital.password, password):
        print("password incorrect")
        return jsonify(error={'Not Found': 'Incorect password'}), 403
    else:
        print("login")
        token = jwt.encode({'email': email,
                            'exp': datetime.utcnow() + timedelta(seconds=5), },
                           app.config['SECRET_KEY'])
        return jsonify({'token': token})


# Book an appointment
@app.route('/book_appointment', methods=['GET', 'POST'])
@token_required
def book_appointment(current_user):
    d_hospital_name = Hospital.query.filter_by(id=request.form.get('hospital_id')).first()
    new_appointment = Appointment(
        date=request.form.get('date'),
        time=request.form.get('time'),
        day=request.form.get('day'),
        user_id=current_user.id,
        hospital_id=request.form.get('hospital_id'),
        hospital_name=d_hospital_name.name,
        user_name=current_user.name,
        status='upcoming'
    )
    db.session.add(new_appointment)
    db.session.commit()
    return jsonify({'success': "Appointment booked"}), 200


# Fetch all Appointments
@app.route('/all_appointments')
def get_all_appointments():
    appointments = db.session.query(Appointment).all()
    if appointments:
        return jsonify(All_Appointments=[all_appointment.to_dict() for all_appointment in appointments]), 200
    else:
        return jsonify({'Error': 'No current appointments'}), 204


# Fetch all Appointments for a user
@app.route('/user/appointments')
@token_required
def get_user_appointments(current_user):
    try:
        appointments = Appointment.query.filter_by(user_id=current_user.id).all()
        if appointments:
            return jsonify(All_Appointments=[all_appointment.to_dict() for all_appointment in appointments]), 200
        else:
            return jsonify({'Error': 'No current appointments'}), 204
    except Exception as e:
        return jsonify({"Error":e})


# get all upcoming appointments of a particular user
@app.route('/upcoming/user/appointment')
@token_required
def get_user_appointment(current_user):
    id = current_user.id
    upcoming_user_appointment = Appointment.query.filter_by(user_id=id, status='upcoming').all()
    print('this')
    if upcoming_user_appointment:
        return jsonify(Upcoming=[upcoming.to_dict() for upcoming in upcoming_user_appointment if datetime.now()
                                 < datetime.strptime(upcoming.date, "%m/%d/%Y")])
    else:
        return jsonify({'Error': 'No current appointments'}), 204


# get all cancled appointments of a particular user
@app.route('/cancled/user/appointment')
@token_required
def get_cancled_user_appointment(current_user):
    id = current_user.id
    try:
        cancled_user_appointment = Appointment.query.filter_by(user_id=id, status='cancled').all()
        print('this')
        if cancled_user_appointment:
            return jsonify(Cancled=[cancled.to_dict() for cancled in cancled_user_appointment])
        else:
            return jsonify({'Error': 'No current appointments'}), 204
    except Exception as e:
        return e


# get all completed appointments of a particular user
@app.route('/completed/user/appointment')
@token_required
def get_completed_user_appointment(current_user):
    id = current_user.id
    try:
        completed_user_appointment = Appointment.query.filter_by(user_id=id, status='completed').all()
        print('this')
        if completed_user_appointment:
            return jsonify(Completed=[completed.to_dict() for completed in completed_user_appointment]), 200
        else:
            return jsonify({'Error': 'No current appointments'}), 204
    except Exception as e:
        return jsonify({'Error': e.message})


# Cancel a User's appointment
@app.route('/user/appointment/cancel', methods=['PATCH'])
@token_required
def cancel_appointment(current_user):
    id = request.form.get('id')
    try:
        appointment = Appointment.query.filter_by(id=id).first()
        if appointment and appointment.user_id == current_user.id and appointment.status == 'upcoming':
            appointment.status = 'cancled'
            db.session.commit()
            return jsonify({'Success': 'Appointment status updated'})
        else:
            return jsonify({'Error': 'Appointment not avaailable'}), 204
    except Exception as e:
        return e


# Complete a User's appointment
@app.route('/user/appointment/complete', methods=['PATCH'])
@token_required
def complete_appointment(current_user):
    id = request.form.get('id')
    try:
        appointment = Appointment.query.filter_by(id=id).first()
        if appointment and appointment.user_id == current_user.id and appointment.status == 'upcoming':
            if datetime.strptime(appointment.date, "%m/%d/%Y") <= datetime.now():
                appointment.status = 'completed'
                db.session.commit()
                return jsonify({'Success': 'Appointment status updated'})
            else:
                return jsonify({'Error': 'The date has not arrived yet'}), 304
        else:
            return jsonify({'Error': 'No current appointment under completed'}), 204
    except Exception as e:
        return e


@app.route('/predict_tumor', methods=['GET', 'POST'])
def predict_tumor():
    imagefile = request.files['image']
    filename = werkzeug.utils.secure_filename(imagefile.filename)
    imagefile.save('./images/'+ filename)
    img = Image.open(imagefile.stream)
    opencvImage = cv2.cvtColor(np.array(img), cv2.COLOR_RGB2BGR)
    img = cv2.resize(opencvImage,(150,150))
    img = img.reshape(1,150,150,3)
    prediction = new_model.predict(img)
    prediction = np.argmax(prediction,axis=1)[0]
    if prediction == 0:
        prediction='Glioma Tumor'
    elif prediction==1:
        print('The model predicts that there is no tumor')
        prediction = 'No Tumor'
    elif prediction==2:
        prediction='Meningioma Tumor'
    else:
        prediction='Pituitary Tumor'

    return jsonify({'predictions': prediction}), 200


# @app.route('/user/logout')
# def user_log_out():
#     logout_user()``
#     return jsonify(logged_out={'success': ' sucessfully logged out'})

if __name__ == '__main__':
    app.run(debug=True)
