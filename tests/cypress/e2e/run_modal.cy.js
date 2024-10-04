describe("Run modal", () => {
    beforeEach(() => {
      cy.visit("/");
      //Importing a data to test
      cy.importing_data_flow('csv');
      //Select variables
      cy.select_flow('sequence_variable', '1');
      cy.select_flow('forecast_variable', '2');
      //Turn panel
      cy.turn_panel();
      cy.trainin_test_inputs_flow();
      cy.run_flow();
    });

    it("'Run modal' visibility", () => {
      cy.get('[data-testid="close_run_modal"]')
      .should('be.visible')
      .click()
      .should('not.be.visible');
    });

    it("'Run modal' table", () => {
      cy.wait(5000);
      cy.compare_table_fixture('iterations_table', 'iterations');
    });

    it("'Run modal' table filter visibility", () => {
      cy.wait(5000);
      cy.get('[data-testid="iterationsfilter-1"]').click({force: true});
      cy.get_filter_option('iterationsfilter-1', '1')
        .should("have.text", "original");
      cy.get_filter_option('iterationsfilter-1', '2')
        .should("have.text", "first");
      cy.get_filter_option('iterationsfilter-1', '3')
        .should("have.text", "second");

      cy.get('[data-testid="iterationsfilter-2"]').click({force: true});
      cy.get_filter_option('iterationsfilter-2', '1')
        .should("have.text", "exact");
      cy.get_filter_option('iterationsfilter-2', '2')
        .should("have.text", "zero_one");
      cy.get_filter_option('iterationsfilter-2', '3')
        .should("have.text", "minus_plus");

      cy.get('[data-testid="iterationsfilter-4"]').click({force: true});
      cy.get_filter_option('iterationsfilter-4', '1')
        .should("have.text", "1");
      cy.get_filter_option('iterationsfilter-4', '2')
        .should("have.text", "2");

      cy.get('[data-testid="iterationsfilter-5"]').click({force: true});
      cy.get_filter_option('iterationsfilter-5', '1')
        .should("have.text", "16");
      cy.get_filter_option('iterationsfilter-5', '2')
        .should("have.text", "32");
    });

    it("'Run modal' table filter functionality", () => {
      cy.wait(5000);
      cy.get('[data-testid="iterationsfilter-1"]').click({force: true});
      cy.get_filter_option('iterationsfilter-1', '1')
        .click({force: true});
      cy.get('[data-testid="iterationsfilter-2"]').click({force: true});
      cy.get_filter_option('iterationsfilter-2', '1')
        .click({force: true});
      cy.get_filter_option('iterationsfilter-2', '2')
        .click({force: true});
      cy.get('[data-testid="iterationsfilter-4"]').click({force: true});
      cy.get_filter_option('iterationsfilter-4', '1')
        .click({force: true});
      cy.get('[data-testid="iterationsfilter-5"]').click({force: true});
      cy.get_filter_option('iterationsfilter-5', '1')
        .click({force: true});
      cy.compare_table_fixture('iterations_table', 'iterations_fil');
    });

    it("'Run modal' start button", () => {
      cy.wait(5000);
      cy.get('[data-testid="startbutton"]').click({force: true});
      cy.get('.loader')
        .should('be.visible');
      cy.get('.shiny-spinner-caption')
        .should('have.text', 'Please wait, this can take several minutes');
    });

});
