describe("Pivot inputs", () => {
  beforeEach(() => {
    cy.visit("/");
    //Importing a data to test
    cy.importing_data_flow();
    //Turn panel
    cy.turn_panel();
    
  });
  // Testing pivot inputs
  it("'Pivot inputs' visibility - Transformations", () => {
    // - Transformations visibility
    cy.log('Continue with pivot inputs tests');
    cy.get('#app-training_inputs-transformation').should('not.be.visible');
    cy.get('#app-training_inputs-transformation').click({force: true});
    cy.get('#app-training_inputs-transformation-list0-label').should('be.visible');
    cy.get('#app-training_inputs-transformation-list0-label').should('have.text', "Original");
    cy.get('#app-training_inputs-transformation-list1-label').should('be.visible');
    cy.get('#app-training_inputs-transformation-list1-label').should('have.text', "First");
    cy.get('#app-training_inputs-transformation-list2-label').should('be.visible');
    cy.get('#app-training_inputs-transformation-list2-label').should('have.text', "Second");
  });
  it("'Pivot inputs' visibility - Scale", () => {
    // - Scale visibility
    cy.get('#app-training_inputs-scale').should('not.be.visible');
    cy.get('#app-training_inputs-scale').click({force: true});
    cy.get('#app-training_inputs-scale-list0-label').should('be.visible');
    cy.get('#app-training_inputs-scale-list0-label').should('have.text', "Exact");
    cy.get('#app-training_inputs-scale-list1-label').should('be.visible');
    cy.get('#app-training_inputs-scale-list1-label').should('have.text', "0 to 1");
    cy.get('#app-training_inputs-scale-list2-label').should('be.visible');
    cy.get('#app-training_inputs-scale-list2-label').should('have.text', "-1 to 1");
  });
  it("'Pivot inputs' visibility - Horizontal", () => {
    // - Horizon visibility
    cy.get('#app-training_inputs-horizon').should('not.be.visible');
    cy.get('#app-training_inputs-horizon > input').should('have.value', '1');
  });
  it("'Pivot inputs' visibility - Input amount", () => {
    // - Input amount visibility
    cy.get('#app-training_inputs-inp_amount').should('not.be.visible');
    cy.get('#app-training_inputs-inp_amount').should('have.text', '');
  });
  it("'Pivot inputs' visibility - LSTM", () => {
    // - LSTM neurons visibility
    cy.get('#app-training_inputs-lstm').should('not.be.visible');
    cy.get('#app-training_inputs-lstm').should('have.text', '');
  });
  it("'Pivot inputs' visibility - LSTM", () => {
    // - Epoch visibility
    cy.get('#app-training_inputs-epoch').should('not.be.visible');
    cy.get('#app-training_inputs-epoch > input').should('have.value', '1');
  });
  it("'Pivot inputs' visibility - Tests", () => {
    // - Tests visibility
    cy.get('#app-training_inputs-tests').should('not.be.visible');
    cy.get('#app-training_inputs-tests > input').should('have.value', '1');
  });
  it("'Pivot inputs' funtionality - Transformations", () => {
    cy.get('#app-training_inputs-transformation').click({force: true});
    cy.get('#app-training_inputs-transformation-list0-label').click();
    cy.get('#app-training_inputs-transformation').should("have.text", "Original");
    cy.get('#app-training_inputs-transformation-list1-label').click();
    cy.get('#app-training_inputs-transformation').should("have.text", "Original, First");
    cy.get('#app-training_inputs-transformation-list2-label').click();
    cy.get('#app-training_inputs-transformation').should("have.text", "Original, First, Second");
  });
  it("'Pivot inputs' funtionality - Scale", () => {
    cy.get('#app-training_inputs-scale').click({force: true});
    cy.get('#app-training_inputs-scale-list0-label').click();
    cy.get('#app-training_inputs-scale').should("have.text", "Exact");
    cy.get('#app-training_inputs-scale-list1-label').click();
    cy.get('#app-training_inputs-scale').should("have.text", "Exact, 0 to 1");
    cy.get('#app-training_inputs-scale-list2-label').click();
    cy.get('#app-training_inputs-scale').should("have.text", "Exact, 0 to 1, -1 to 1");
  });
  it("'Pivot inputs' funtionality - Horizon", () => {
    cy.get('#app-training_inputs-horizon button:nth-child(1)').click({force: true});
    cy.get('#app-training_inputs-horizon > input').should('have.value', '2');
    cy.get('#app-training_inputs-horizon button:nth-child(2)').click({force: true});
    cy.get('#app-training_inputs-horizon > input').should('have.value', '1');
  });
  it("'Pivot inputs' funtionality - Input amount", () => {
    cy.get('#app-training_inputs-inp_amount').type('ab1,+-2', {force: true}).should('have.value', '1,2');
  });
  it("'Pivot inputs' funtionality - LSTM", () => {
    cy.get('#app-training_inputs-lstm').type('ab16,+-32', {force: true}).should('have.value', '16,32');
  });
  it("'Pivot inputs' funtionality - Epoch", () => {
    cy.get('#app-training_inputs-epoch button:nth-child(1)').click({force: true});
    cy.get('#app-training_inputs-epoch > input').should('have.value', '2');
    cy.get('#app-training_inputs-epoch button:nth-child(2)').click({force: true});
    cy.get('#app-training_inputs-epoch > input').should('have.value', '1');
  });
  it("'Pivot inputs' funtionality - Tests", () => {
    cy.get('#app-training_inputs-tests button:nth-child(1)').click({force: true});
    cy.get('#app-training_inputs-tests > input').should('have.value', '2');
    cy.get('#app-training_inputs-tests button:nth-child(2)').click({force: true});
    cy.get('#app-training_inputs-tests > input').should('have.value', '1');
  });    
    // cy.wait(5000);
    // cy.log('Run page button functionality');
    // cy.get('#app-page_buttons-runbutton').should('be.visible');
    // cy.get('#app-page_buttons-runbutton').click();
    
    // cy.wait(5000);
    // cy.log('Run modal functionality');
    // cy.get("#app-run_modal-make_modal-hideModal").should('be.visible');
    // cy.log('Table');
    // cy.fixture('iterations').then((expectedData) => {
    //   cy.getDataFromDatatable('app-run_modal-iterations_table').then((currentData) => {
    //     expect(currentData).to.deep.equal(JSON.stringify(expectedData));
    //   });
    // });
    // cy.get('#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(2) input[type="search"]').click({force: true});
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(2) div:nth-child(2) .option:nth-child(1)").should("have.text", "original");
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(2) div:nth-child(2) .option:nth-child(2)").should("have.text", "first");
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(2) div:nth-child(2) .option:nth-child(3)").should("have.text", "second");
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(2) div:nth-child(2) .option:nth-child(1)").click({force: true});
    
    // cy.get('#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(3) input[type="search"]').click({force: true});
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(3) div:nth-child(2) .option:nth-child(1)").should("have.text", "exact");
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(3) div:nth-child(2) .option:nth-child(2)").should("have.text", "zero_one");
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(3) div:nth-child(2) .option:nth-child(3)").should("have.text", "minus_plus");
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(3) div:nth-child(2) .option:nth-child(1)").click({force: true});
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(3) div:nth-child(2) .option:nth-child(2)").click({force: true});
    
    // cy.get('#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(5) input[type="search"]').click({force: true});
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(5) div:nth-child(2) .option:nth-child(1)").should("have.text", "1");
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(5) div:nth-child(2) .option:nth-child(2)").should("have.text", "2");
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(5) div:nth-child(2) .option:nth-child(1)").click({force: true});
    
    // cy.get('#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(6) input[type="search"]').click({force: true});
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(6) div:nth-child(2) .option:nth-child(1)").should("have.text", "16");
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(6) div:nth-child(2) .option:nth-child(2)").should("have.text", "32");
    // cy.get("#app-run_modal-iterations_table thead tr:nth-child(2) td:nth-child(6) div:nth-child(2) .option:nth-child(1)").click({force: true});
});
