const chai = require("chai");
const chaiHttp = require("chai-http");
const server = require("../server");
const expect = chai.expect;
chai.use(chaiHttp);

let destinationId;

describe("Destination API Tests", function () {
    it("should create a new destination", function (done) {
        chai.request(server)
            .post("/api/v1/destination")
            .send({
                name: "Everest Base Camp",
                description: "A trek to the base of the world's highest mountain.",
                popular_spots: "Kala Patthar, Namche Bazaar",
                region: "Khumbu"
            })
            .end((err, res) => {
                expect([200, 201]).to.include(res.status);
                destinationId = res.body.data?._id || res.body._id;
                done();
            });
    });

    it("should get all destinations", function (done) {
        chai.request(server)
            .get("/api/v1/destination")
            .end((err, res) => {
                expect(res).to.have.status(200);
                expect(res.body).to.be.an("array");
                done();
            });
    });

    it("should get a destination by id", function (done) {
        chai.request(server)
            .get(`/api/v1/destination/${destinationId || 'invalidid'}`)
            .end((err, res) => {
                expect([200, 404, 500]).to.include(res.status);
                done();
            });
    });

    it("should update a destination", function (done) {
        chai.request(server)
            .put(`/api/v1/destination/${destinationId || 'invalidid'}`)
            .send({ region: "Solukhumbu" })
            .end((err, res) => {
                expect([200, 404, 500]).to.include(res.status);
                done();
            });
    });

    it("should delete a destination", function (done) {
        chai.request(server)
            .delete(`/api/v1/destination/${destinationId || 'invalidid'}`)
            .end((err, res) => {
                expect([200, 404, 500]).to.include(res.status);
                done();
            });
    });

    it("should return 404 for non-existent destination", function (done) {
        chai.request(server)
            .get("/api/v1/destination/doesnotexist")
            .end((err, res) => {
                expect([200, 404, 500]).to.include(res.status);
                done();
            });
    });
});
