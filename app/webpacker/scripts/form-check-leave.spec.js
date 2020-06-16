import FormCheckLeave from "./form-check-leave"

describe("FormCheckLeave", () => {
  describe('init', () => {
    it ('does not initialise if no module is passed to it', () =>{
      expect(new FormCheckLeave()).toEqual({})
    })

    describe("when a Forms state needs to be tracked so users do not lose their unsaved data", () =>{

    })
  })


})
