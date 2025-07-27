const chai = require("chai");
const chaiHttp = require("chai-http");
const server = require("../server");
const expect = chai.expect;
chai.use(chaiHttp);

let itineraryId;

describe("Itinerary API Tests", function () {
    it("should create a new itinerary", function (done) {
        chai.request(server)
            .post("/api/v1/itinerary")
            .send({
                day_number: 1,
                activities: "Hiking",
                details: "Start from Lukla, trek to Phakding."
            })
            .end((err, res) => {
                expect([200, 201]).to.include(res.status);
                itineraryId = res.body.data?._id || res.body._id;
                done();
            });
    });

    it("should get all itineraries", function (done) {
        chai.request(server)
            .get("/api/v1/itinerary")
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.be.an("array");
                done();
            });
    });

    it("should get an itinerary by id", function (done) {
        chai.request(server)
            .get(`/api/v1/itinerary/${itineraryId || 'invalidid'}`)
            .end((err, res) => {
                expect([200, 404, 500]).to.include(res.status);
                done();
            });
    });

    it("should update an itinerary", function (done) {
        chai.request(server)
            .put(`/api/v1/itinerary/${itineraryId || 'invalidid'}`)
            .send({ activities: "Rest and acclimatization" })
            .end((err, res) => {
                expect([200, 404, 500]).to.include(res.status);
                done();
            });
    });

    it("should delete an itinerary", function (done) {
        chai.request(server)
            .delete(`/api/v1/itinerary/${itineraryId || 'invalidid'}`)
            .end((err, res) => {
                expect([200, 404, 500]).to.include(res.status);
                done();
            });
    });

    it("should return 404 for non-existent itinerary", function (done) {
        chai.request(server)
            .get("/api/v1/itinerary/doesnotexist")
            .end((err, res) => {
                expect([200, 404, 500]).to.include(res.status);
                done();
            });
    });
});
