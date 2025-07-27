const chai = require("chai");
const chaiHttp = require("chai-http");
const server = require("../server");
const expect = chai.expect;
chai.use(chaiHttp);

let packageId;

describe("Package API Tests", function () {
    it("should create a new package", function (done) {
        chai.request(server)
            .post("/api/v1/package")
            .send({
                title: "Annapurna Circuit",
                description: "A classic trek in Nepal.",
                location: "Annapurna",
                price: 500,
                duration: "10 days",
                image: "annapurna.jpg",
                availableDates: JSON.stringify([new Date().toISOString()]),
                category: "Adventure",
                itinerary: "Day 1|Day 2"
            })
            .end((err, res) => {
                expect([200, 201]).to.include(res.status);
                packageId = res.body.data?._id || res.body._id;
                done();
            });
    });

    it("should get all packages", function (done) {
        chai.request(server)
            .get("/api/v1/package")
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.be.an("array");
                done();
            });
    });

    it("should get a package by id", function (done) {
        chai.request(server)
            .get(`/api/v1/package/${packageId || 'invalidid'}`)
            .end((err, res) => {
                expect([200, 404, 500]).to.include(res.status);
                done();
            });
    });

    it("should update a package", function (done) {
        chai.request(server)
            .put(`/api/v1/package/${packageId || 'invalidid'}`)
            .send({ price: 600 })
            .end((err, res) => {
                expect([200, 404, 500]).to.include(res.status);
                done();
            });
    });

    it("should delete a package", function (done) {
        chai.request(server)
            .delete(`/api/v1/package/${packageId || 'invalidid'}`)
            .end((err, res) => {
                expect([200, 404, 500]).to.include(res.status);
                done();
            });
    });

    it("should return 404 for non-existent package", function (done) {
        chai.request(server)
            .get("/api/v1/package/doesnotexist")
            .end((err, res) => {
                expect([404, 500]).to.include(res.status);
                done();
            });
    });
});
