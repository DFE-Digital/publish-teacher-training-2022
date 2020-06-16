import FormCheckLeave from "./form-check-leave"

describe("FormCheckLeave", () => {
  describe('init', () => {
    it ('does not initialise if no module is passed to it', () =>{
      expect(new FormCheckLeave()).toEqual({})
    })

    describe("when a Forms state needs to be tracked so users do not lose their unsaved data", () =>{
      it('should bind a submit/change event to form', () =>{
        // Note: not a <form> because JSDOM throws a fit https://github.com/jsdom/jsdom/issues/1937
        document.body.innerHTML = `
          <div data-ga-event-form="Some form" id="test-form">
            <input type="text" data-ga-event-form-input="A ticked item">
            <input type="submit">
          </div>
          `
        let $form = document.getElementById('test-form')
        $form.addEventListener = jest.fn()

        new FormCheckLeave($form)
        expect($form.addEventListener).toHaveBeenNthCalledWith(1,'submit', expect.any(Function) )
        expect($form.addEventListener).toHaveBeenNthCalledWith(2,'change', expect.any(Function))
      })
    })
  })
})
